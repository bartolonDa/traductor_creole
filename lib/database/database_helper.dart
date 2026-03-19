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
    
    // Versión 2 para asegurar que los cambios de columnas se apliquen
    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade, 
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute("DROP TABLE IF EXISTS traducciones");
      await _createDB(db, newVersion);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE traducciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        textoOriginal TEXT NOT NULL,
        textoTraducido TEXT NOT NULL,
        idiomaOrigen TEXT NOT NULL,
        idiomaDestino TEXT NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');

    // Datos semilla para que la app funcione offline desde el inicio
    List<Map<String, String>> frasesSemilla = [
      {"es": "hola", "ht": "Bonjou"},
      {"es": "¿cómo estás?", "ht": "Kijan ou ye?"},
      {"es": "necesito ayuda", "ht": "Mwen bezwen èd"},
      {"es": "¿dónde está el hospital?", "ht": "Kote lopital la ye?"},
      {"es": "tengo hambre", "ht": "Mwen grangou"},
      {"es": "gracias", "ht": "Mèsi"},
      {"es": "ayuda por favor", "ht": "Tanpri ede mwen"},
      {"es": "¿dónde hay agua?", "ht": "Kote ki gen dlo?"},
      {"es": "no entiendo", "ht": "Mwen pa konprann"},
      {"es": "buenos días", "ht": "Bonjou"},
      {"es": "buenas noches", "ht": "Bonswa"},
    ];

    for (var frase in frasesSemilla) {
      await db.insert('traducciones', {
        'textoOriginal': frase['es']!,
        'textoTraducido': frase['ht']!,
        'idiomaOrigen': 'ES',
        'idiomaDestino': 'HT',
        'fecha': DateTime.now().toString(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllTraducciones() async {
    final db = await instance.database;
    return await db.query('traducciones', orderBy: 'id DESC');
  }

  Future<int> insertTraduccion(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(
      'traducciones', 
      row, 
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // ── FUNCIÓN PARA BORRAR UNA FILA ESPECÍFICA ──
  Future<int> deleteTraduccion(int id) async {
    final db = await instance.database;
    return await db.delete(
      'traducciones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTraducciones() async {
    final db = await instance.database;
    await db.delete('traducciones');
  }
}