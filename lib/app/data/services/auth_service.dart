import 'dart:convert';
import 'dart:io' show File;

import 'package:get_server/get_server.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:crypto/crypto.dart';
import 'package:mysql1/mysql1.dart';

import '../_sql/quary_exception.dart';
import '../providers/db_provider.dart';
import '../_sql/quary_builder.dart';

class AuthService extends GetxService {
  final quaryBuilder = QuaryBuilder(db: 'project_db', table: 'USERS');
  final session = QuaryBuilder(db: 'project_db', table: 'session');
  final provider = Get.find<DbProvider>();

  String? _token(Map<String, dynamic> data) {
    final claimSet = JwtClaim(
      expiry: DateTime.now().add(30.days),
      issuer: 'project_server',
      issuedAt: DateTime.now(),
      payload: data,
    );
    return TokenUtil.generateToken(claim: claimSet);
  }

  Future<Map<String, dynamic>> signUp(Map<dynamic, dynamic> data) async {
    quaryBuilder.clear();
    quaryBuilder.insert([
      'email',
      'password',
      'name',
      'image',
      'address',
    ]);
    var bytes1 = utf8.encode(data['password']); // data being hashed
    data['password'] = sha256.convert(bytes1).toString();
    try {
      var connection = await provider.connection;
      var image = File('./assets/profile.jpg').readAsBytesSync();

      await connection.query(
        quaryBuilder.toString(),
        [
          data['email'],
          data['password'],
          data['name'],
          Blob.fromBytes(image),
          data['address'],
        ],
      );
      quaryBuilder
        ..clear()
        ..select(['id'])
        ..where('email = "${data['email']}"');
      var result = await connection.query(quaryBuilder.toString());
      var id = result.firstOrNull?[0];
      session.insert([
        'token',
        'expiration_date',
        'user_id',
      ]);

      var token = _token(
        {
          'id': id,
        },
      );
      connection.query(
        session.toString(),
        [
          token,
          DateTime.now().add(30.days).toIso8601String(),
          id,
        ],
      );
      return {
        'token': token,
        'data': {
          'id': id,
          'image': data['image'] == null ? image : null,
        },
        'message': 'user created',
      };
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } on ResponseException catch (_) {
      rethrow;
    } catch (e) {
      print(e);
      throw ResponseException.server();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    quaryBuilder.clear();
    var connection = await provider.connection;
    var bytes1 = utf8.encode(password); // data being hashed
    password = sha256.convert(bytes1).toString();
    quaryBuilder
      ..select([
        'id',
        'name',
        'image',
        'address',
      ])
      ..where(
        '''
        email = "$email" 
        AND
        password = "$password"
    ''',
      );
    try {
      var result = await connection.query(quaryBuilder.toString());
      if (result.isEmpty) {
        throw ResponseException(
          message: 'invalid email or password',
          error: ErrorType.badRequest,
        );
      }
      var data = result.firstOrNull?.fields;
      data?['image'] = data['image'].toBytes();
      var token = _token(
        {
          'id': data?['id'],
        },
      );
      session.update(
        [
          'token',
          'expiration_date',
        ],
        [
          token,
          DateTime.now().add(30.days).toIso8601String(),
        ],
        condition: '''
        user_id = "${data?['id']}"  
        ''',
      );

      await connection.query(
        quaryBuilder.toString(),
      );
      return {
        'data': data,
        'token': token,
        'message': 'login successful',
      };
    } on MySqlException catch (e) {
      throw ResponseException(
        message: e.message,
        error: ErrorType.badRequest,
      );
    } on ResponseException catch (_) {
      rethrow;
    } catch (e) {
      print(e);
      throw ResponseException.server();
    }
  }

  Future<int> checkAuth(String token) async {
    try {
      var claim = TokenUtil.getClaims(token);
      var connection = await provider.connection;

      session
        ..select([
          'expiration_date',
        ])
        ..where(
          '''
        user_id = "${claim.payload['id']}" 
    ''',
        );

      var result = await connection.query(session.toString());

      var data = result.first.fields;
      if (data['expiration_date'].isBefore(
        DateTime.now(),
      )) throw Exception();
      return data['${claim.payload['id']}'];
    } catch (e) {
      throw ResponseException(
        message: e.toString(),
        error: ErrorType.unAuthenticated,
      );
    }
  }
}
