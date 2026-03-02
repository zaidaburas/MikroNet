import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;
  String templates="""
    CREATE TABLE templates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      password_type TEXT,
      photo TEXT,
      rows INTEGER,
      columns INTEGER,
      username_length INTEGER,
      password_length INTEGER,
      fontsize INTEGER,
      username_pattern TEXT,
      password_pattern TEXT,
      username_location_x REAL,
      username_location_y REAL,
      password_location_x REAL,
      password_location_y REAL
    );
  """;

  String batches="""
    CREATE TABLE batches (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      template_id INTEGER,
      generated_cards INTEGER,
      cards_type TEXT,
      card_prefix TEXT,
      card_suffix TEXT,
    );
  """;

  String savedLogins="""
    CREATE TABLE saved_logins (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      host TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      port INTEGER DEFAULT 22,
      name TEXT
    );
  """;

  

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initializeDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> _initializeDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "mikrotik.db");
    Database database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
    );
    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
    Batch mybatch = db.batch();

    mybatch.execute(templates);
    mybatch.execute(batches);
    mybatch.execute(savedLogins);
    // mybatch.execute(inss);

    await mybatch.commit();

    // ????? ????? ???? ??????? ???.
  }

  Future<List<Map>> readData(String sql) async {
    Database? myDb = await db;
    return await myDb!.rawQuery(sql);
  }

  Future<int> insertData(String sql) async {
    Database? myDb = await db;
    return await myDb!.rawInsert(sql);
  }

  Future<int> updateData(String sql) async {
    Database? myDb = await db;
    return await myDb!.rawUpdate(sql);
  }

  Future<int> deleteData(String sql) async {
    Database? myDb = await db;
    return await myDb!.rawDelete(sql);
  }
}
