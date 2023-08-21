import 'package:get_server/get_server.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    switch (context.method) {
      case Method.post:
        controller.login(context);
      case _:
        controller.noMethod(context);
    }
    return WidgetEmpty();
  }
}
