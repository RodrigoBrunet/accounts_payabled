import 'package:accounts_payable/models/account_model.dart';
import 'package:intl/intl.dart';
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
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
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

    await db.execute('''
      CREATE TABLE totais_mensais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mes TEXT NOT NULL,
        total REAL NOT NULL
    )
  ''');
  }

  Future<int> insert(Account account) async {
    Database db = await instance.database;
    return await db.insert(table, account.toMap());
  }

  Future<int> insertOrUpadateTotalMensal(String mes, double total) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> existing = await db.query(
      'totais_mensais',
      where: 'mes = ?',
      whereArgs: [mes],
    );

    if (existing.isEmpty) {
      Map<String, dynamic> row = {
        'mes': mes,
        'total': total,
      };
      int result = await db.insert('totais_mensais', row);
      return result;
    } else {
      int result = await db.update(
        'totais_mensais',
        {'total': total},
        where: 'mes = ?',
        whereArgs: [mes],
      );
      return result;
    }
  }

  Future<List<Map<String, dynamic>>> queryTotaisMensais() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query('totais_mensais');
    return result;
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

  Future<List<Account>> queryContasPagas() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: 'paid = ?',
      whereArgs: [1],
    );

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

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<double> calcTotalPaidOnMouth() async {
    Database db = await instance.database;
    DateTime now = DateTime.now();
    String firstDayOfMonth =
        DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    String lastDayOfMonth =
        DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> filteredMaps = await db.query(
      table,
      where: "paid = ? AND dueDate BETWEEN ? AND ?",
      whereArgs: [1, firstDayOfMonth, lastDayOfMonth],
    );

    double total = 0;
    for (var map in filteredMaps) {
      total += map['value'];
    }

    String mesAtual = DateFormat('yyyy-MM').format(DateTime.now());
    await insertOrUpadateTotalMensal(mesAtual, total);

    return total;
  }
}
