import 'package:get_server/get_server.dart';
import 'package:project_server/app/data/services/auth_service.dart';
import 'package:project_server/app/data/services/books_service.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';

class BooksController extends GetxController {
  final authService = Get.find<AuthService>();
  final booksService = Get.find<BooksService>();

  void addBook(BuildContext context) async {
    try {
      // var token = TokenUtil.getTokenFromHeader(context.request);
      // var id = await authService.checkAuth(token);
      var payload = await context.payload();
      if (payload == null || payload.isEmpty) {
        throw ResponseException(
          message: 'no body',
          error: ErrorType.badRequest,
        );
      }
      


      var details = await booksService.addBook(payload);
      context.statusCode(200);
      
      await context.sendJson(details);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    }
  }

  void getBooks(BuildContext context) async {
    try {
      var token = TokenUtil.getTokenFromHeader(context.request);
      await authService.checkAuth(token);

      int? id = int.tryParse(context.param('id') ?? '');
      int page = int.tryParse(context.param('page') ?? '') ?? 1;
      String filter = context.param('filter') ?? '';
      int? category = int.tryParse(context.param('category') ?? '');
      page = page < 1 ? 1 : page;

      var result = id == null
          ? await booksService.getBooks(page, filter, category)
          : await booksService.getBook(id);
      context.statusCode(200);
      context.request.response?.header('Access-Control-Allow-Origin', '*');
      context.request.response?.header('Access-Control-Allow-Methods',
          'GET, POST, OPTIONS, PUT, PATCH, DELETE');
      context.request.response?.header(
          'Access-Control-Allow-Headers', 'X-Requested-With,content-type');
      context.request.response?.header(
          'Access-Control-Allow-Credentials', 'X-Requested-With,content-type');
      context.request.response
          ?.header('Access-Control-Allow-Credentials', true);
      await context.sendJson(result);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    }
  }

  void editBook(BuildContext context) async {
    try {
      var token = TokenUtil.getTokenFromHeader(context.request);
      var user = await authService.checkAuth(token);
      int? id = int.tryParse(context.param('id') ?? '');
      var payload = await context.payload();

      if (id == null) {
        context.statusCode(401);
        await context.sendJson({'message': 'parameter id required'});
        return;
      } else if (payload == null) {
        context.statusCode(401);
        await context.sendJson({'message': 'body required'});
        return;
      }
      if (!(payload['image'] is MultipartUpload? &&
          payload['image_in'] is MultipartUpload? &&
          payload['image_other'] is MultipartUpload?)) {
        throw ResponseException(
            message: 'invalid image', error: ErrorType.badRequest);
      }

      var result = await booksService.editBook(id, payload, user);
      context.statusCode(200);
      context.request.response?.header('Access-Control-Allow-Origin', '*');
      context.request.response?.header('Access-Control-Allow-Methods',
          'GET, POST, OPTIONS, PUT, PATCH, DELETE');
      context.request.response?.header(
          'Access-Control-Allow-Headers', 'X-Requested-With,content-type');
      context.request.response?.header(
          'Access-Control-Allow-Credentials', 'X-Requested-With,content-type');
      context.request.response
          ?.header('Access-Control-Allow-Credentials', true);
      await context.sendJson(result);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    }
  }

  void deleteBook(BuildContext context) async {
    try {
      var token = TokenUtil.getTokenFromHeader(context.request);
      var user = await authService.checkAuth(token);
      int? id = int.tryParse(context.param('id') ?? '');
      if (id == null) {
        context.statusCode(401);
        await context.sendJson({'message': 'parameter id required'});
        return;
      }
      var result = await booksService.deleteBook(id, user);
      context.statusCode(200);
      context.request.response?.header('Access-Control-Allow-Origin', '*');
      context.request.response?.header('Access-Control-Allow-Methods',
          'GET, POST, OPTIONS, PUT, PATCH, DELETE');
      context.request.response?.header(
          'Access-Control-Allow-Headers', 'X-Requested-With,content-type');
      context.request.response?.header(
          'Access-Control-Allow-Credentials', 'X-Requested-With,content-type');
      context.request.response
          ?.header('Access-Control-Allow-Credentials', true);
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
