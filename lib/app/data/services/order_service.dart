import 'package:get_server/get_server.dart';
import 'package:mysql1/mysql1.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import '../providers/db_provider.dart';
import '../_sql/quary_builder.dart';

class OrderService extends GetxService {
  final provider = Get.find<DbProvider>();
  final quaryBuilder = QuaryBuilder(db: 'provider_db', table: 'ORDER');

  Future addOrder(List<List> data) async {
    try {
      var connection = await provider.connection;
      quaryBuilder
        ..insert(
          ['book_id', 'buyer_id'],
        );
      connection.queryMulti(
        quaryBuilder.toString(),
        data,
      );
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } catch (e) {
      print(e);
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    var connection = await provider.connection;
    quaryBuilder
      ..select([
        '*',
      ])
      ..where(
        '''
        id = "$id" 
    ''',
      );
    try {
      var result = await connection.query(quaryBuilder.toString());
      if (result.isEmpty) {
        return {
          'data': [],
          'message': 'book not found',
        };
      }
      return {
        'data': result.toList().map((e) => e.fields).toList(),
        'message': 'book details',
      };
    } catch (e) {
      throw ResponseException.server();
    }
  }
}
