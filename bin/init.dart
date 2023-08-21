import 'package:project_server/app/data/_sql/db_init.dart';

Future<void> main(List<String> args) async {
  String? arg = args.isNotEmpty ? args[0] : null;
  initDb(arg);
}
