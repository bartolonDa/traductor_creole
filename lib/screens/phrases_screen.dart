import 'package:flutter/material.dart';
import '../models/traduccion.dart';
import '../services/traduccion_service.dart';

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({super.key});

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen> {
  final TraduccionService _service = TraduccionService();
  List<Traduccion> _lista = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final data = await _service.obtenerTraducciones();
    setState(() {
      _lista = data;
      _loading = false;
    });
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
      body: Column(
        children: [
          // ── HEADER ──
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
                      Text('Mis Frases',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: text)),
                      Text('Frases que usas con frecuencia',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: text3)),
                    ],
                  ),
                ),
                const Text('🇲🇽 🇭🇹', style: TextStyle(fontSize: 20)),
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
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 56, color: text3.withOpacity(.4)),
                            const SizedBox(height: 12),
                            Text(
                              'Aún no tienes frases guardadas.\n¡Empieza a traducir para verlas aquí!',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: text3),
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
                            final f1 = item.idiomaOrigen == "ES" ? '🇲🇽' : '🇭🇹';
                            final f2 = item.idiomaDestino == "ES" ? '🇲🇽' : '🇭🇹';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: surface,
                                  border: Border.all(color: border),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 1))
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.textoOriginal,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: text)),
                                          const SizedBox(height: 3),
                                          Text(item.textoTraducido,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2563EB))),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF4FF),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Text('$f1 → $f2',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF2563EB))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.volume_up_outlined,
                                        color: text3, size: 20),
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
    );
  }
}
