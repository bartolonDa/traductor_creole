import '../database/database_helper.dart';
import '../models/traduccion.dart';

class TraduccionService {
  Future<void> agregarTraduccion(Traduccion traduccion) async {
    await DatabaseHelper.instance.insertTraduccion(traduccion.toMap());
  }

  Future<List<Traduccion>> obtenerTraducciones() async {
    final data = await DatabaseHelper.instance.getAllTraducciones();
    return data.map((e) => Traduccion.fromMap(e)).toList();
  }
}
