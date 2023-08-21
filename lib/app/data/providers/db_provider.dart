import 'package:mysql1/mysql1.dart';
import 'package:get_server/get_server.dart';
import 'package:project_server/config.dart';

class DbProvider extends GetxService {
  MySqlConnection? _connection;
  final _settings = ConnectionSettings(
    host: DatabaseConfig.host,
    port: DatabaseConfig.port,
    user: DatabaseConfig.user,
    password: DatabaseConfig.password == '' ? null : DatabaseConfig.password,
    db: DatabaseConfig.db,
  );

  Future<MySqlConnection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await MySqlConnection.connect(_settings);

    return _connection!;
  }
}
