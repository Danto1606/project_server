import 'package:get_server/get_server.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import 'package:project_server/app/data/services/auth_service.dart';

class LoginController extends GetxController {
  final service = Get.find<AuthService>();

  void login(BuildContext context) async {
    var payload = await context.payload();

    if (payload == null) {
      context.statusCode(400);
      await context.sendJson({'message': 'required field email'});
      return;
    }

    if (payload['email'] == null) {
      context.statusCode(400);
      await context.sendJson({'message': 'required field email'});
      return;
    }

    if (payload['password'] == null) {
      context.statusCode(400);
      await context.sendJson({'message': 'required field password'});
      return;
    }
    try {
      var response = await service.login(payload['email'], payload['password']);
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
      await context.sendJson(response);
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
