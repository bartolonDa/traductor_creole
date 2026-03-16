import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({super.key});

  @override
  State<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends State<PhrasesScreen> {
  final FlutterTts _tts = FlutterTts();

  // Frases temporales (luego vendrán de SQLite)
  final List<Map<String, String>> frases = [
    {"es": "Hola", "ht": "Bonjou"},
    {"es": "Buenos días", "ht": "Bon maten"},
    {"es": "Buenas tardes", "ht": "Bon apremidi"},
    {"es": "Buenas noches", "ht": "Bon nwit"},
    {"es": "Gracias", "ht": "Mesi"},
    {"es": "Por favor", "ht": "Tanpri"},
    {"es": "¿Cuánto cuesta?", "ht": "Konbyen sa koute?"},
    {"es": "Necesito ayuda", "ht": "Mwen bezwen èd"},
    {"es": "¿Dónde está el hospital?", "ht": "Ki kote lopital la ye?"},
    {"es": "¿Habla español?", "ht": "Èske ou pale panyòl?"},
  ];

  Future speak(String text) async {
    await _tts.setLanguage("fr-FR");
    await _tts.setPitch(1);
    await _tts.speak(text);
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
          // HEADER
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
                        'Frases útiles',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: text,
                        ),
                      ),
                      Text(
                        'Toca una frase para escucharla',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: text3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🇲🇽 🇭🇹', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),

          Divider(height: 1, color: border),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              itemCount: frases.length,
              itemBuilder: (_, i) {
                final item = frases[i];

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
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["es"]!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: text,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                item["ht"]!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF4FF),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  '🇲🇽 → 🇭🇹',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        IconButton(
                          icon: Icon(
                            Icons.volume_up_outlined,
                            color: text3,
                            size: 22,
                          ),
                          onPressed: () {
                            speak(item["ht"]!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
