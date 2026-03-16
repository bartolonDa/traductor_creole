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

  @override
  void initState() {
    super.initState();
    HistoryScreenStateNotifier.reload = _cargar;
    _cargar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await _service.obtenerTraducciones();
    if (mounted)
      setState(() {
        _lista = data;
        _loading = false;
      });
  }

  Future<void> _limpiar() async {
    await _service.limpiarTraducciones();
    setState(() {
      _lista.clear();
    });
  }

  bool _mostrarConfirm = false;

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
              // ── HEADER ──
              Container(
                color: surface,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 16,
                  right: 16,
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: text,
                            ),
                          ),
                          Text(
                            'Tus traducciones recientes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_lista.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _mostrarConfirm = true;
                          });
                        },
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: border),

              // ── LISTA ──
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _lista.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 56,
                              color: text3.withOpacity(.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no tienes traducciones.\n¡Empieza a traducir!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: text3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          itemCount: _lista.length,
                          itemBuilder: (_, i) {
                            final item = _lista[i];
                            final f1 = item.idiomaOrigen == "ES"
                                ? '🇲🇽'
                                : '🇭🇹';
                            final f2 = item.idiomaDestino == "ES"
                                ? '🇲🇽'
                                : '🇭🇹';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surface,
                                  border: Border.all(color: border),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '$f1 → $f2',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatFecha(item.fecha),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: text3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      item.textoOriginal,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: text,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.textoTraducido,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),

          // ── CONFIRMACIÓN INLINE (sin showDialog) ──
          if (_mostrarConfirm)
            Container(
              color: Colors.black.withOpacity(.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Limpiar historial',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¿Borrar todas las traducciones?',
                        style: TextStyle(fontSize: 14, color: text3),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _mostrarConfirm = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: border,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Cancelar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => _mostrarConfirm = false);
                                await _service.limpiarTraducciones();
                                await _cargar();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Limpiar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
