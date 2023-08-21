import 'package:get_server/get_server.dart';

import 'app/data/bindings/database_binding.dart';
import 'app/routes/app_pages.dart';
import 'config.dart';

void main() {
  server();
}

void server() async {
  runApp(
    GetServer(
      host: ServerConfig.host,
      port: ServerConfig.port,
      jwtKey: 'project name',
      getPages: AppPages.routes,
      initialBinding: InitBindings(),
    ),
  );
}
