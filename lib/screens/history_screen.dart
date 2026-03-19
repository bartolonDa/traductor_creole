import 'package:flutter/material.dart';
import '../models/traduccion.dart';
import '../services/traduccion_service.dart';

class HistoryScreenStateNotifier {
  static VoidCallback? reload;
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TraduccionService _service = TraduccionService();
  List<Traduccion> _lista = [];
  bool _loading = true;
  bool _mostrarConfirmTodo = false;
  int? _idParaBorrar; 

  @override
  void initState() {
    super.initState();
    HistoryScreenStateNotifier.reload = _cargar;
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await _service.obtenerTraducciones();
    if (mounted) {
      setState(() {
        _lista = data;
        _loading = false;
      });
    }
  }

  // ── FUNCIÓN DE BORRADO ──
  Future<void> _borrarIndividual(int id) async {
    try {
      await _service.borrarTraduccionIndividual(id);
      await _cargar();
      setState(() => _idParaBorrar = null);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Traducción eliminada"), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("Error al borrar: $e");
    }
  }

  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
      return 'Hace ${diff.inDays} días';
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111318) : const Color(0xFFF5F3EF);
    final surface = isDark ? const Color(0xFF1E2230) : Colors.white;
    final border = isDark ? const Color(0xFF2D3348) : const Color(0xFFE2DED6);
    final text = isDark ? const Color(0xFFF0EDE8) : const Color(0xFF1C1917);
    final text3 = isDark ? const Color(0xFF6B7280) : const Color(0xFFA8A29E);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: surface,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 16, right: 16, bottom: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Historial', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text)),
                          Text('Tus traducciones recientes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text3)),
                        ],
                      ),
                    ),
                    if (_lista.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _mostrarConfirmTodo = true),
                        child: const Text('Limpiar todo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.red)),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: border),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _lista.isEmpty
                    ? _buildVacio(text3)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                        itemCount: _lista.length,
                        itemBuilder: (_, i) {
                          final item = _lista[i];
                          return _buildTarjetaHistorial(item, surface, border, text, text3);
                        },
                      ),
              ),
            ],
          ),

          if (_mostrarConfirmTodo) _buildDialogoSobrecapa(
            surface, text, text3, border, 
            "¿Borrar todo el historial?", 
            () async {
              setState(() => _mostrarConfirmTodo = false);
              await _service.limpiarTraducciones();
              _cargar();
            },
            () => setState(() => _mostrarConfirmTodo = false)
          ),

          if (_idParaBorrar != null) _buildDialogoSobrecapa(
            surface, text, text3, border, 
            "¿Borrar esta traducción?", 
            () => _borrarIndividual(_idParaBorrar!),
            () => setState(() => _idParaBorrar = null)
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaHistorial(Traduccion item, Color surface, Color border, Color text, Color text3) {
    final f1 = item.idiomaOrigen == "ES" ? '🇲🇽' : '🇭🇹';
    final f2 = item.idiomaDestino == "ES" ? '🇲🇽' : '🇭🇹';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Para que el icono no se corte
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('$f1 → $f2', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(_formatFecha(item.fecha), style: TextStyle(fontSize: 10, color: text3)),
                ],
              ),
              const SizedBox(height: 8),
              Text(item.textoOriginal, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: text)),
              Text(item.textoTraducido, style: const TextStyle(fontSize: 14, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              onPressed: () => setState(() => _idParaBorrar = item.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio(Color text3) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 56, color: text3.withOpacity(.4)),
          const SizedBox(height: 12),
          Text('Historial vacío', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: text3)),
        ],
      ),
    );
  }

  Widget _buildDialogoSobrecapa(Color surface, Color text, Color text3, Color border, String titulo, VoidCallback onConfirm, VoidCallback onCancel) {
    return Container(
      color: Colors.black.withOpacity(.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: text)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(12)),
                        child: const Text('No', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onConfirm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: const Text('Sí, borrar', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}