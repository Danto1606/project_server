import 'package:get_server/get_server.dart';

import '../providers/db_provider.dart';
import '../services/auth_service.dart';
import '../services/books_service.dart';
import '../services/order_service.dart';
import '../services/user_service.dart';
import '../services/users_service.dart';
import '../services/category_service.dart';

class InitBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(DbProvider());
    Get.lazyPut(() => AuthService());
    Get.lazyPut(() => UsersService());
    Get.lazyPut(() => UserService());
    Get.lazyPut(() => CategoryService());
    Get.lazyPut(() => BooksService());
    Get.lazyPut(() => OrderService());
  }
}
