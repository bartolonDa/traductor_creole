import '../database/database_helper.dart';
import '../models/traduccion.dart';

class TraduccionService {
  // Variable para controlar el estado del interruptor (puedes setearla desde el Perfil)
  bool modoOfflineForzado = false;

  // ── FUNCIÓN: Guarda en el cel ──
  Future<void> agregarTraduccion(Traduccion traduccion) async {
    await DatabaseHelper.instance.insertTraduccion(traduccion.toMap());
  }

  // ── FUNCIÓN: Carga el historial ──
  Future<List<Traduccion>> obtenerTraducciones() async {
    final data = await DatabaseHelper.instance.getAllTraducciones();
    return data.map((e) => Traduccion.fromMap(e)).toList();
  }

  // ── FUNCIÓN: Borra todo el historial ──
  Future<void> limpiarTraducciones() async {
    await DatabaseHelper.instance.deleteAllTraducciones();
  }

  // ── FUNCIÓN: Borra una sola traducción ──
  Future<void> borrarTraduccionIndividual(int id) async {
    await DatabaseHelper.instance.deleteTraduccion(id);
  }

  // ── NÚCLEO: BUSCADOR LOCAL ESTRATÉGICO ──
  Future<String?> buscarTraduccionLocal(String texto, String origen, String destino) async {
    final db = await DatabaseHelper.instance.database;
    
    // Limpieza de entrada para asegurar coincidencia con las semillas
    final String queryTexto = texto.trim().toLowerCase().replaceAll('.', '');

    final List<Map<String, dynamic>> res = await db.query(
      'traducciones', 
      where: 'textoOriginal = ? AND idiomaOrigen = ? AND idiomaDestino = ?',
      whereArgs: [
        queryTexto, 
        origen.toUpperCase(), 
        destino.toUpperCase()
      ],
      limit: 1, 
    );

    if (res.isNotEmpty) {
      return res.first['textoTraducido'] as String;
    }
    
    return null; 
  }

  // ── NUEVO: VALIDACIÓN DE MODO OFFLINE ──
  // Esta función ayudará a la HomeScreen a decidir si debe o no usar la API
  bool debeBloquearAPI() {
    return modoOfflineForzado;
  }
}