import 'package:get_server/get_server.dart';
import 'package:mysql1/mysql1.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import '../providers/db_provider.dart';
import '../_sql/quary_builder.dart';

class CategoryService extends GetxService {
  final provider = Get.find<DbProvider>();
  final quaryBuilder = QuaryBuilder(db: 'provider_db', table: 'CATEGORIES');

  Future<Map<String, dynamic>> addCategory(Map data) async {
    try {
      quaryBuilder
        ..insert(
          data.keys.toList(),
        );
      var connection = await provider.connection;
      await connection.query(
        quaryBuilder.toString(),
        data.values.toList(),
      );
      quaryBuilder
        ..clear()
        ..select(['id'])
        ..where('title = "${data['title']}"');
      var result = await connection.query(quaryBuilder.toString());
      data['id'] = result.firstOrNull?[0];
      return {
        'data': data,
        'message': 'category created',
      };
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } catch (_) {
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> getCategories(int page) async {
    var connection = await provider.connection;
    quaryBuilder
      ..clear()
      ..select([
        'title',
        'id',
      ])
      ..where(
        '''
        true
    ''',
        limit: (index: 25 * (page - 1), ammount: 25),
      );
    try {
      var result = await connection.query(quaryBuilder.toString());

      return {
        'data': result.toList().map((e) => e.fields).toList(),
        'message': 'list of categories',
      };
    } catch (_) {
      throw ResponseException.server();
    }
  }
}
