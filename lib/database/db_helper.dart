import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mydatabase.db');
    // ignore: avoid_print
    // ignore: avoid_print
    // ignore: avoid_print
    print('Ruta de la base de datos: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT, name TEXT)');
        await db.execute(
            'CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, amount REAL, description TEXT, date TEXT, category TEXT)');
        await db.execute('''
          CREATE TABLE deleted_expenses (
            id INTEGER PRIMARY KEY,
            userId INTEGER,
            description TEXT,
            category TEXT,
            amount REAL,
            date TEXT
          )
        ''');
      },
    );
  }
}
