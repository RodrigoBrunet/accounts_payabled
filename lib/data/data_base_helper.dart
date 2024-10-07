import 'package:accounts_payable/models/account_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseHelper {
  static const _databaseName = 'AccountDatabase.db';
  static const _dataBaseVersion = 1;
  static const table = 'accounts';

  DataBaseHelper._privateConstructor();
  static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _dataBaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY,
        description TEXT NOT NULL,
        value REAL NOT NULL,
        dueDate TEXT NOT NULL,
        paid INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insert(Account account) async {
    Database db = await instance.database;
    return await db.insert(table, account.toMap());
  }

  Future<List<Account>> queryAllRows() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'],
        description: maps[i]['description'],
        value: maps[i]['value'],
        dueDate: maps[i]['dueDate'],
        paid: maps[i]['paid'] == 1,
      );
    });
  }

  Future<int> updateStatus(int id, bool paid) async {
    Database db = await instance.database;
    return await db.update(
      table,
      {'paid': paid ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
