import 'package:get_server/get_server.dart';

import '../controllers/category_controller.dart';

class CategoryView extends GetView<CategoryController> {
  @override
  Widget build(BuildContext context) {
    if (context.request.header('Authorization') == null) {
      return StatusCode(
        child: Json({'message': 'no authorization header'}),
        statusCode: 401,
      );
    }
    switch (context.method) {
      case Method.post:
        controller.addBook(context);
      case Method.get:
        controller.getCategories(context);
      case _:
        controller.noMethod(context);
    }
    return WidgetEmpty();
  }
}
