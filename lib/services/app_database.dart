
import 'package:path/path.dart';
import 'package:ledger/services/transactions_repository.dart' as tr;
import 'package:ledger/services/accounts_repository.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  AppDatabase._init();
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;

    _db = await initDb('ledger.db');
    return _db!;
  }

  Future<Database> initDb(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    _db = await openDatabase(path, version: 1,
                onCreate: (Database db, int version) async {
                            await db.execute(Account.createTableSql);
                            await db.execute(tr.Transaction.createTableSql);
                          }
                );
    return _db!;
  }

  Future close() async {
    final db = await instance.db;
    db.close();
  }
}