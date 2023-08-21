import 'package:get_server/get_server.dart';
import '../providers/db_provider.dart';
import '../_sql/quary_builder.dart';

class UsersService extends GetxService {
  final provider = Get.find<DbProvider>();
  final quaryBuilder = QuaryBuilder(db: 'provider_db', table: 'USERS');

  Future<Map<String, dynamic>> getUser(int id) async {
    var connection = await provider.connection;
    quaryBuilder
      ..select(['*'])
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
          'message': 'user not found',
        };
      }
      return {
        'data': result.firstOrNull?.fields,
        'message': 'user details',
      };
    } catch (e) {
      return {
        'error': 'server error',
        'message': 'error getting user',
      };
    }
  }

  Future<Map<String, dynamic>> getUsers(
      {int start = 0, int amount = 25}) async {
    var connection = await provider.connection;
    quaryBuilder
      ..select(['*'])
      ..where(
        '''
        true
    ''',
        limit: (index: start, ammount: 25),
      );
    try {
      var result = await connection.query(quaryBuilder.toString());
      return {
        'data': result.fields,
        'message': 'list of users',
      };
    } catch (e) {
      return {
        'error': 'server error',
        'message': 'error getting users',
      };
    }
  }

  Future<Map<String, dynamic>> filterUser(String filter,
      [int index = 0, int ammount = 25]) async {
    var connection = await provider.connection;
    quaryBuilder
      ..select(['*'])
      ..where(
        '''
        name LIKE "%$filter%" 
        OR email LIKE "%$filter%"
    ''',
        orderby: 'name',
        limit: (index: index, ammount: ammount),
      );
    try {
      var result = await connection.query(quaryBuilder.toString());
      if (result.isEmpty) {
        return {'error': 'invalid details'};
      }
      return {
        'data': result.fields,
        'message': 'list of users',
      };
    } catch (e) {
      return {
        'error': 'server error',
        'message': 'error getting users',
      };
    }
  }
}
