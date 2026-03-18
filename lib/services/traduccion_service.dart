import '../database/database_helper.dart';
import '../models/traduccion.dart';

class TraduccionService {
  // ── FUNCIÓN ORIGINAL: Guarda en el cel ──
  Future<void> agregarTraduccion(Traduccion traduccion) async {
    await DatabaseHelper.instance.insertTraduccion(traduccion.toMap());
  }

  // ── FUNCIÓN ORIGINAL: Carga el historial ──
  Future<List<Traduccion>> obtenerTraducciones() async {
    final data = await DatabaseHelper.instance.getAllTraducciones();
    return data.map((e) => Traduccion.fromMap(e)).toList();
  }

  // ── FUNCIÓN ORIGINAL: Borra todo ──
  Future<void> limpiarTraducciones() async {
    await DatabaseHelper.instance.deleteAllTraducciones();
  }

  // ── NUEVO: BUSCADOR OFFLINE ──
  // Esta función busca si la frase ya fue traducida antes para ahorrar internet
  Future<String?> buscarTraduccionLocal(String texto, String origen, String destino) async {
    final db = await DatabaseHelper.instance.database;
    
    // Buscamos la frase ignorando espacios y mayúsculas
    final List<Map<String, dynamic>> res = await db.query(
      'traducciones', // Asegúrate de que el nombre de la tabla en SQLite sea este
      where: 'textoOriginal = ? AND idiomaOrigen = ? AND idiomaDestino = ?',
      whereArgs: [
        texto.trim().toLowerCase(), 
        origen.toUpperCase(), 
        destino.toUpperCase()
      ],
      limit: 1, // Solo necesitamos la más reciente
    );

    if (res.isNotEmpty) {
      // Si la encontró, devolvemos el texto traducido
      return res.first['textoTraducido'] as String;
    }
    
    return null; // Si devuelve null, la app sabrá que DEBE usar internet
  }
}