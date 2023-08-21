import 'package:get_server/get_server.dart';
import 'package:mysql1/mysql1.dart';
import 'package:project_server/app/data/_sql/quary_exception.dart';
import '../providers/db_provider.dart';
import '../_sql/quary_builder.dart';

class BooksService extends GetxService {
  final provider = Get.find<DbProvider>();
  final quaryBuilder = QuaryBuilder(db: 'provider_db', table: 'BOOKS');

  Future<Map<String, dynamic>> addBook(Map data) async {
    data['image'] = Blob.fromBytes(data['image'].data);
    quaryBuilder
      ..insert(
        data.keys.toList(),
      );
    try {
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
      var id = result.firstOrNull?[0];
      return {
        'data': {'id': id},
        'message': 'book created',
      };
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

  Future<Map<String, dynamic>> getBook(int id) async {
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
        'data': result.firstOrNull?.fields,
        'message': 'book details',
      };
    } catch (e) {
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> getBooks(int page, String filter,
      [int? category]) async {
    var connection = await provider.connection;
    var catCon = category == null ? '' : 'AND category_id = "$category"';
    quaryBuilder
      ..select([
        '*',
      ])
      ..where(
        '''
        title LIKE "%$filter%"
        $catCon
    ''',
        orderby: 'title',
        limit: (index: 25 * (page - 1), ammount: 25),
      );
    try {
      var result = await connection.query(quaryBuilder.toString());

      return {
        'data': result.toList().map((e) => e.fields).toList(),
        'message': 'list of books',
      };
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } catch (e) {
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> editBook(int id, Map payload, int user) async {
    try {
      if (payload['image'] is MultipartUpload) {
        payload['image'] = Blob.fromBytes(payload['image'].data);
      }
      var connection = await provider.connection;
      quaryBuilder
        ..select(['id'])
        ..where('''
          id = "$id"
          ''');
      var result = await connection.query(quaryBuilder.toString());
      if (result.isEmpty) {
        throw ResponseException(
            message: 'book not found', error: ErrorType.badRequest);
      }
      quaryBuilder.update(
        payload.keys.toList(),
        payload.values.toList(),
        condition: '''
        id = "$id"
        ''',
      );
      await connection.query(quaryBuilder.toString());

      return {
        'data': ' book updated',
        'message': 'book update successful',
      };
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } on ResponseException catch (_) {
      rethrow;
    } catch (e) {
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> deleteBook(int id, int user) async {
    try {
      var connection = await provider.connection;
      quaryBuilder.delete(
        '''
        id = "$id"
        AND
        user_id = "$user"
        ''',
      );
      await connection.query(
        quaryBuilder.toString(),
      );
      var result = await getBook(id);
      if (result['data'].isNotEmpty) {
        throw ResponseException(
          message: 'unable to delete',
          error: ErrorType.badRequest,
        );
      }
      return {
        'data': ' book deleted',
        'message': 'book deleted successful',
      };
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } on ResponseException catch (_) {
      rethrow;
    } catch (e) {
      throw ResponseException.server();
    }
  }
}
