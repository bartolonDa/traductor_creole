import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('traductor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE traducciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        texto_original TEXT NOT NULL,
        texto_traducido TEXT NOT NULL,
        idioma_origen TEXT NOT NULL,
        idioma_destino TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllTraducciones() async {
    final db = await instance.database;
    return await db.query('traducciones');
  }

  Future<int> insertTraduccion(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('traducciones', row);
  }
}
