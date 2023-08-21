import 'package:get_server/get_server.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import 'package:project_server/app/data/services/auth_service.dart';
import 'package:project_server/app/data/services/order_service.dart';

class OrderController extends GetxController {
  final authService = Get.find<AuthService>();
  final orderService = Get.find<OrderService>();

  void addOrder(BuildContext context) async {
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

      var details = await orderService.addOrder(payload['data']);
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

  void getOrder(BuildContext context) async {
    try {
      var token = TokenUtil.getTokenFromHeader(context.request);
      var id = await authService.checkAuth(token);
      var payload = await context.payload();
      if (payload == null || payload.isEmpty) {
        throw ResponseException(
          message: 'no body',
          error: ErrorType.badRequest,
        );
      }

      var details = await orderService.getOrder(id);
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

  void noMethod(BuildContext context) async {
    context.statusCode(405);
    await context.sendJson({
      'message':
          '${context.request.method} method not allowed on route ${context.request.path}'
    });
  }
}
