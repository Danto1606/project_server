import 'package:get_server/get_server.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import 'package:project_server/app/data/services/auth_service.dart';
import 'package:project_server/app/data/services/category_service.dart';

class CategoryController extends GetxController {
  final authService = Get.find<AuthService>();
  final categotyService = Get.find<CategoryService>();

  void addBook(BuildContext context) async {
    try {
      var token = TokenUtil.getTokenFromHeader(context.request);
      await authService.checkAuth(token);
      var payload = await context.payload();
      if (payload == null || payload.isEmpty) {
        throw ResponseException(
          message: 'no body',
          error: ErrorType.badRequest,
        );
      }
      var details = await categotyService.addCategory(payload);
      context.statusCode(200);
      await context.sendJson(details);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    }
  }

  void getCategories(BuildContext context) async {
    try {
      // var token = TokenUtil.getTokenFromHeader(context.request);
      // await authService.checkAuth(token);
      int page = int.tryParse(context.param('page') ?? '') ?? 1;
      page = page < 1 ? 1 : page;
      var result = await categotyService.getCategories(page);
      context.statusCode(200);
      await context.sendJson(result);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    }
  }

  void noMethod(BuildContext context) async {
    context.statusCode(405);
    await context.sendJson({
      'message':
          '${context.request.method} method not allowed on route ${context.request.path}'
    });
  }
}
