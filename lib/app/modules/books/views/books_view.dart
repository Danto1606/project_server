import 'package:get_server/get_server.dart';

import '../controllers/books_controller.dart';

class BooksView extends GetView<BooksController> {
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
        controller.getBooks(context);
      case Method.put:
        controller.editBook(context);
      case Method.delete:
        controller.deleteBook(context);
      case _:
        controller.noMethod(context);
    }
    return WidgetEmpty();
  }
}
