import 'package:get_server/get_server.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import 'package:project_server/app/data/services/auth_service.dart';
import 'package:project_server/app/data/services/user_service.dart';

class UserController extends GetxController {
  final authService = Get.find<AuthService>();
  final userService = Get.find<UserService>();

  void create(BuildContext context) async {
    try {
      final payload = await context.payload();

      if (payload == null) {
        context.statusCode(400);
        await context.sendJson({'message': 'invalid input'});
      } else {
        var details = await authService.signUp(payload);
        context.statusCode(200);
        await context.sendJson(details);
      }
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
      return;
    }
  }

  void getUser(BuildContext context) async {
    try {
      if (context.request.header('Authorization') == null) {
        throw ResponseException(
          message: 'could not find bearer',
          error: ErrorType.unAuthenticated,
        );
      }
      var token = TokenUtil.getTokenFromHeader(context.request);
      var id = await authService.checkAuth(token);
      var details = await userService.getUserDetail(id);
      context.statusCode(200);
      await context.sendJson(details);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    } catch (e) {
      context.send('${e.runtimeType} ${e.toString()}');
    }
  }

  void updateUser(BuildContext context) async {
    try {
      if (context.request.header('Authorization') == null) {
        throw ResponseException(
          message: 'could not find bearer',
          error: ErrorType.unAuthenticated,
        );
      }
      final payload = await context.payload();
      var token = TokenUtil.getTokenFromHeader(context.request);
      var id = await authService.checkAuth(token);
      payload?.remove('id');
      if (payload == null || payload.isEmpty) {
        throw ResponseException(
          message: 'no body',
          error: ErrorType.badRequest,
        );
      }

      var details = await userService.updateUserDetail(id, payload);
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
      await context.sendJson(details);
    } on ResponseException catch (e) {
      context.statusCode(e.error.code);
      await context.sendJson(e.toJson());
    }
  }

  // void deleteUser(BuildContext context) async {
  //   try {
  //     var token = TokenUtil.getTokenFromHeader(context.request);
  //     var id = await authService.checkAuth(token);
  //     var result = await userService.deleteUser(id);
  //     context.statusCode(200);
  //     await context.sendJson(result);
  //   } on ResponseException catch (e) {
  //     context.statusCode(e.error.code);
  //     await context.sendJson(e.toJson());
  //   }
  // }

  void noMethod(BuildContext context) async {
    context.statusCode(405);
    await context.sendJson({
      'message':
          '${context.request.method} method not allowed on route ${context.request.path}'
    });
  }
}
