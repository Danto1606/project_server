import 'package:get_server/get_server.dart';

import '../controllers/user_controller.dart';

class UserView extends GetView<UserController> {
  @override
  Widget build(BuildContext context) {
    switch (context.method) {
      case Method.post:
        controller.create(context);
      case Method.put:
        controller.updateUser(context);
      case Method.get:
        controller.getUser(context);
      // case Method.delete:
      //   controller.deleteUser(context);
      case _:
        controller.noMethod(context);
    }
    return WidgetEmpty();
  }
}
