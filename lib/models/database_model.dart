import '../services/database.dart';

String implode(List<String> list, String delimiter) {
  return list.join(delimiter);
}

String quoteValue(String value) {
  return "'$value'";
}

String generateInsertQuery(Map<String, dynamic> data, String table) {
  List<String> fields = data.keys.toList();
  List<String> values =
      data.values.map((value) => quoteValue(value.toString())).toList();

  String fieldsStr = implode(fields, ',');
  String valuesStr = implode(values, ',');

  return 'INSERT INTO $table ($fieldsStr) VALUES ($valuesStr)';
}

class DBModel extends SqlDb {

  Future<List> select(String table,
      [String? where,
      String? fields,
      String? order,
      String? limit,
      String? offset,
      String? group]) async {
    try {
      where = (where == null || where.isEmpty) ? '' : 'WHERE $where';
      fields = (fields == null || fields.isEmpty) ? '*' : fields;
      order = (order == null || order.isEmpty) ? '' : 'ORDER BY $order';
      limit = (limit == null || limit.isEmpty) ? '' : 'LIMIT $limit';
      offset = (offset == null || offset.isEmpty) ? '' : 'OFFSET $offset';
      group = (group == null || group.isEmpty) ? '' : 'GROUP BY $group';

      String query = '''
      SELECT $fields FROM $table $where
      $group
      $order
      $limit
      $offset
      ''';

      List<Map> response = await readData(query);
      return response;
    } catch (e) {
      //print('Error in select: $e');
      return [];
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    List<String> fields = data.keys.toList();
    List<String> values =
        data.values.map((value) => quoteValue(value.toString())).toList();

    String fieldsStr = implode(fields, ',');
    String valuesStr = implode(values, ',');

    String query = 'INSERT INTO $table ($fieldsStr) VALUES ($valuesStr)';
    try {
      int response = await insertData(query);
      return response;
    } catch (e) {
      //print('Error in insert: $e');
      return -1;
    }
  }

  Future<int> update(String table, Map<String, dynamic> data,
      [String? where]) async {
    List<String> set = [];
    data.forEach((field, value) {
      set.add('$field=${quoteValue(value.toString())}');
    });

    String setStr = implode(set, ',');
    String query = 'UPDATE $table SET $setStr';

    if (where != null && where.isNotEmpty) {
      query += ' WHERE $where';
    }

    try {
      int response = await updateData(query);
      return response;
    } catch (e) {
      //print('Error in update: $e');
      return -1;
    }
  }

  Future<int> delete(String table, [String? where]) async {
    String query = 'DELETE FROM $table';
    if (where != null && where.isNotEmpty) {
      query += ' WHERE $where';
    }
    try {
      int response = await deleteData(query);
      return response;
    } catch (e) {
      //print('Error in delete: $e');
      return -1;
    }
  }
}
