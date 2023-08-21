import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:project_server/config.dart';

Future<void> initDb(String? arg) async {
  MySqlConnection conn;
  try {
    print('****************setting up DATABASE**************');
    conn = await _connect();
    if (arg != null) {
      if (arg == '--drop-table') _deleteDb(conn);
    }
    ;
    await _createDb(conn);
    await _createUserTable(conn);
    await _createCategoryTable(conn);
    await _createBookTable(conn);
    await _createOrderTable(conn);
    await _createSessionTable(conn);
    // await _createRequestTable(conn);
    // await _createMessageTable(conn);
    await conn.close();
    print('****************DATABASE READY*******************');
  } on SocketException catch (_) {
    print(
      'ERROR: connecting to database server failed',
    );
    print('****************TERMINATED***********************');
  } catch (e) {
    print(
      e.toString(),
    );
    print('****************TERMINATED***********************');
  }
}

const String dbName = DatabaseConfig.db;

Future<MySqlConnection> _connect() async {
  var settings = ConnectionSettings(
    host: DatabaseConfig.host,
    port: DatabaseConfig.port,
    user: DatabaseConfig.user,
    password: DatabaseConfig.password == '' ? null : DatabaseConfig.password,
  );
  return await MySqlConnection.connect(settings);
}

Future<void> _createDb(MySqlConnection conn) async {
  var result = await conn.query(
    '''SELECT schema_name 
    FROM information_schema.schemata 
    WHERE schema_name = "$dbName";
    ''',
  );
  print(result.fields.toString());
  if (result.isEmpty) {
    await conn.query('CREATE DATABASE $dbName;');
    print('created DATABASE');
  } else {
    print('DATABASE already exists');
  }
}

Future<void> _deleteDb(MySqlConnection conn) async {
  await conn.query('DROP DATABASE $dbName;');
  print('dropping DATABASE');
}

Future<void> _createUserTable(MySqlConnection conn) async {
  print('creating USERS table...');
  var result = await conn.query('''
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_name = "USERS" AND table_schema = "$dbName";
    ''');
  if (result.isEmpty) {
    await conn.query('''
        CREATE TABLE $dbName.USERS (
        id int NOT NULL AUTO_INCREMENT,
        email varchar(20) NOT NULL,
        password varchar(64) NOT NULL,
        name varchar(25) NOT NULL,
        image mediumblob NOT NULL,
        address varchar(40) NOT NULL,
        reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE (email),
        PRIMARY KEY (id)
    );
    ''');
    await conn.query(
      '''
      CREATE UNIQUE INDEX name_email
      ON $dbName.USERS (name, email);
    ''',
    );
    await conn.query(
      '''
      CREATE UNIQUE INDEX user
      ON $dbName.USERS (id, password);
    ''',
    );
    print('USERS table created');
  } else {
    print('USERS  table already exists');
  }
}

Future<void> _createBookTable(MySqlConnection conn) async {
  print('creating BOOKS table...');
  var result = await conn.query('''
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_name = "BOOKS" AND table_schema = "$dbName";
    ''');
  if (result.isEmpty) {
    await conn.query('''
        CREATE TABLE $dbName.BOOKS (
        id int NOT NULL AUTO_INCREMENT,
        title varchar(30) NOT NULL,
        author varchar(30) NOT NULL,
        image mediumblob NOT NULL,
        publisher varchar(25) NOT Null,
        category_id int NOT NULL,
        user_id int NOT NULL,
        price float NOT NULL,
        condition_ int NOT NULL Default 3,
        description text,
        reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        FOREIGN KEY (user_id) REFERENCES USERS(id),
        FOREIGN KEY (category_id) REFERENCES CATEGORIES(id)
    );
    ''');
    print('BOOKS table created');
  } else {
    print('BOOKS  table already exists');
  }
}

Future<void> _createCategoryTable(MySqlConnection conn) async {
  print('creating CATEGORIES table...');
  var result = await conn.query('''
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_name = "CATEGORIES" AND table_schema = "$dbName";
    ''');
  if (result.isEmpty) {
    await conn.query('''
        CREATE TABLE $dbName.CATEGORIES (
        id int NOT NULL AUTO_INCREMENT,
        title varchar(30) NOT NULL,
        reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE (title),
        PRIMARY KEY (id)
    );
    ''');
    print('CATEGORIES table created');
  } else {
    print('CATEGORIES  table already exists');
  }
}

Future<void> _createOrderTable(MySqlConnection conn) async {
  print('creating ORDERS table...');
  var result = await conn.query('''
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_name = "ORDERS" AND table_schema = "$dbName";
    ''');
  if (result.isEmpty) {
    await conn.query('''
        CREATE TABLE $dbName.ORDERS (
        id int NOT NULL AUTO_INCREMENT,
        buyer_id int NOT NULL,
        book_id int NOT NULL,
        reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        FOREIGN KEY (buyer_id) REFERENCES USERS(id)
    );
    ''');
    print('ORDERS table created');
  } else {
    print('ORDERS  table already exists');
  }
}

// Future<void> _createMessageTable(MySqlConnection conn) async {
//   print('creating MESSAGES table...');
//   var result = await conn.query('''
//     SELECT table_name
//     FROM information_schema.tables
//     WHERE table_name = "MESSAGES" AND table_schema = "$dbName";
//     ''');
//   if (result.isEmpty) {
//     await conn.query('''
//         CREATE TABLE $dbName.MESSAGES (
//         id int NOT NULL AUTO_INCREMENT,
//         sender_id int NOT NULL,
//         receiver_id int NOT NULL,
//         book_id int ,
//         reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
//         PRIMARY KEY (id),
//         FOREIGN KEY (sender_id) REFERENCES USERS(id),
//         FOREIGN KEY (receiver_id) REFERENCES USERS(id),
//         FOREIGN KEY (book_id) REFERENCES BOOKS(id)
//     );
//     ''');
//     print('MESSAGES table created');
//   } else {
//     print('MESSAGES  table already exists');
//   }
// }

// Future<void> _createRequestTable(MySqlConnection conn) async {
//   print('creating REQUESTS table...');
//   var result = await conn.query('''
//     SELECT table_name
//     FROM information_schema.tables
//     WHERE table_name = "REQUESTS" AND table_schema = "$dbName";
//     ''');
//   if (result.isEmpty) {
//     await conn.query('''
//         CREATE TABLE $dbName.REQUESTS (
//         id int NOT NULL AUTO_INCREMENT,
//         requester_id int NOT NULL,
//         title varchar(30) NOT NULL,
//         author varchar(30) NOT NULL,
//         category_id int,
//         reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
//         PRIMARY KEY (id),
//         FOREIGN KEY (category_id) REFERENCES CATEGORIES(id)
//     );
//     ''');
//     print('REQUESTS table created');
//   } else {
//     print('REQUESTS  table already exists');
//   }
// }

Future<void> _createSessionTable(MySqlConnection conn) async {
  print('creating SESSION table...');
  var result = await conn.query('''
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_name = "SESSION" AND table_schema = "$dbName";
    ''');
  if (result.isEmpty) {
    await conn.query('''
        CREATE TABLE $dbName.SESSION (
        id int NOT NULL AUTO_INCREMENT,
        user_id int NOT NULL,
        expiration_date TIMESTAMP Not null,
        token text not null,
        reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        FOREIGN KEY (user_id) REFERENCES USERS(id)
    );
    ''');
    print('SESSION table created');
  } else {
    print('SESSION  table already exists');
  }
}
