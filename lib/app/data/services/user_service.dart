import 'package:get_server/get_server.dart';
import 'package:mysql1/mysql1.dart';
import '../_sql/quary_exception.dart';
import '../providers/db_provider.dart';
import '../_sql/quary_builder.dart';

class UserService extends GetxService {
  final quaryBuilder = QuaryBuilder(db: 'project_db', table: 'USERS');
  final provider = Get.find<DbProvider>();

  Future<Map<String, dynamic>> getUserDetail(int id) async {
    try {
      quaryBuilder.clear();
      var connection = await provider.connection;
      quaryBuilder
        ..select([
          'id',
          'email',
          'name',
          'image',
          'lat',
          'lng',
        ])
        ..where(
          '''
        id = "$id" 
    ''',
        );

      var result = await connection.query(quaryBuilder.toString());
      if (result.isEmpty) {
        throw ResponseException(
          message: 'invalid token',
          error: ErrorType.unAuthenticated,
        );
      }
      var data = result.firstOrNull?.fields;
      Blob blob = data!['image'];
      data['image'] = blob.toBytes();
      return {
        'data': data,
        'message': 'user details',
      };
    } on MySqlException catch (_) {
      throw ResponseException(
        message: 'invalid token',
        error: ErrorType.unAuthenticated,
      );
    } on ResponseException catch (_) {
      rethrow;
    } catch (e) {
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> updateUserDetail(
    int id,
    Map payload,
  ) async {
    try {
      var connection = await provider.connection;
      quaryBuilder.update(
        payload.keys.toList(),
        payload.values.toList(),
        condition: '''
        id = "${id}"  
        ''',
      );
      await connection.query(quaryBuilder.toString(),);

      return {
        'data': ' user updated',
        'message': 'user update successful',
      };
    } on MySqlException catch (_) {
      throw ResponseException(
        message: 'invalid data',
        error: ErrorType.badRequest,
      );
    } catch (e) {
      throw ResponseException.server();
    }
  }

//   Future<Map<String, dynamic>> deleteUser(int id) async {
//     try {
//       var connection = await provider.connection;
//       quaryBuilder.delete(
//         '''
//         id = "$id"
//         ''',
//       );
//       await connection.query(
//         quaryBuilder.toString(),
//       );
//       return {
//         'data': ' removed user',
//         'message': 'deleted user successful',
//       };
//     } on ResponseException catch (_) {
//       rethrow;
//     } catch (e) {
//       print(e);
//       throw ResponseException.server();
//     }
//   }
}
