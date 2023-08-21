import 'package:get_server/get_server.dart';

import '../controllers/books_controller.dart';

class BooksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BooksController>(
      () => BooksController(),
    );
  }
}
