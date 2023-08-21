import 'quary_exception.dart';

class QuaryBuilder {
  late final String db;
  late String table;
  String? _statement;
  QuaryBuilder({
    required this.db,
    required this.table,
  });

  @override
  String toString() => _statement ?? 'no valid quary';
  String? get statement => _statement;

  void select(List<String> args) {
    var statement = 'SELECT';
    for (var a in args) {
      statement = '$statement $a,';
    }
    statement =
        statement.replaceRange(statement.length - 1, null, '\nFrom $table');
    _statement = statement;
  }

  void insert(
    List args,
  ) {
    var columns = '(';
    var values = '(';

    for (var arg in args) {
      columns = '$columns$arg, ';
      values = '$values?, ';
    }
    columns = columns.replaceRange(columns.length - 2, null, ')');
    values = values.replaceRange(values.length - 2, null, ')');

    _statement = '''INSERT INTO $table $columns  
    VALUES $values''';
  }

  void delete(String condition) {
    _statement = 'DELETE FROM $table';
    where(condition);
  }

  void update(List args, List val, {required String condition}) {
    var statement = '''UPDATE $table
    SET''';
    for (var arg in args) {
      statement = '$statement $arg=val,';
    }
    _statement = statement.replaceRange(statement.length - 1, null, '');
    where(condition);
  }

  void where(
    String condition, {
    ({int? index, int ammount})? limit,
    String? orderby,
  }) {
    if (_statement == null) {
      throw QuaryException(
        message: '''invalid statement
        the where should be called after a base statement
    ''',
      );
    }
    orderby = orderby == null ? '' : ' ORDER BY $orderby';
    if (limit case null) {
      _statement = '''$_statement 
        WHERE $condition
        $orderby;
        ''';
    } else if (limit case (index: null, :var ammount)) {
      _statement = '''$_statement 
      WHERE $condition
      $orderby
      LIMIT $ammount;
      
      ''';
    } else if (limit case (:var index, :var ammount)) {
      _statement = '''$_statement 
      WHERE $condition
      $orderby
      LIMIT $index, $ammount;
      
      ''';
    }
  }

  void clear() => _statement = null;
}

void main(List<String> args) {
  QuaryBuilder(db: 'db', table: 'table').where('condition');
}
