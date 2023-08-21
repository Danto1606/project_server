import 'package:get_server/get_server.dart';

import '../controllers/order_controller.dart';

class OrderView extends GetView<OrderController> {
  @override
  Widget build(BuildContext context) {
    switch (context.method) {
      case Method.post:
        controller.addOrder(context);
      case Method.get:
        controller.getOrder(context);
      case _:
        controller.noMethod(context);
    }
    return WidgetEmpty();
  }
}
