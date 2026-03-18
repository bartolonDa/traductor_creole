import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/traduccion.dart';
import '../services/traduccion_service.dart';
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── SERVICIOS ──
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final TraduccionService _service = TraduccionService();
  
  List<Traduccion> _lista = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";
  late FlutterTts _tts;

  // ── ESTADO DE LA UI ──
  String _idiomaActualOrigen = "es";
  String _idiomaActualDestino = "ht";
  String _resultadoTraduccion = "";
  bool _traduciendo = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);
    _cargarDatos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── CARGAR HISTORIAL LOCAL ──
  Future<void> _cargarDatos() async {
    final data = await _service.obtenerTraducciones();
    setState(() => _lista = data);
  }

  // ── LÓGICA DE VOZ (SPEECH TO TEXT) ──
  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _idiomaActualOrigen == "es" ? "es_MX" : "fr_FR",
          onResult: (result) {
            setState(() => _spokenText = result.recognizedWords);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      
      if (_spokenText.isNotEmpty) {
        _procesarTraduccion(_spokenText);
      }
    }
  }

  // ── LÓGICA DE AUDIO (TEXT TO SPEECH) ──
  Future<void> _hablar(String texto, String idioma) async {
    try {
      if (idioma == "es") {
        await _tts.setLanguage("es-MX");
      } else {
        await _tts.setLanguage("fr-FR");
      }
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(texto);
    } catch (e) {
      debugPrint("Error en TTS: $e");
    }
  }

  // ── NÚCLEO: TRADUCCIÓN INTELIGENTE (OFFLINE/ONLINE) ──
  Future<void> _procesarTraduccion(String texto) async {
    // 1. LIMPIEZA TOTAL: Pasamos a minúsculas, quitamos espacios y eliminamos puntos finales
    // Esto asegura que "Hola." o "HOLA" coincidan con tus datos semilla
    final textoLimpio = texto.trim().toLowerCase().replaceAll('.', ''); 
    
    if (textoLimpio.isEmpty) return;

    setState(() => _traduciendo = true);

    // 2. INTENTO OFFLINE: Buscar en SQLite (Diccionario Local)
    String? local = await _service.buscarTraduccionLocal(
      textoLimpio, _idiomaActualOrigen, _idiomaActualDestino
    );

    if (local != null) {
      setState(() {
        _resultadoTraduccion = local;
        _traduciendo = false;
        _spokenText = "";
      });
      await _hablar(local, _idiomaActualDestino);
      return; 
    }

    // 3. INTENTO ONLINE: Usar API si no está en el cel y hay internet
    final traduccionTexto = await _api.traducirTexto(
      texto: textoLimpio,
      source: _idiomaActualOrigen,
      target: _idiomaActualDestino,
    );

    setState(() => _traduciendo = false);

    if (traduccionTexto != null) {
      setState(() {
        _resultadoTraduccion = traduccionTexto;
        _spokenText = "";
      });

      final nueva = Traduccion(
        textoOriginal: textoLimpio,
        textoTraducido: traduccionTexto,
        idiomaOrigen: _idiomaActualOrigen.toUpperCase(),
        idiomaDestino: _idiomaActualDestino.toUpperCase(),
        fecha: DateTime.now().toString(),
      );

      // Guardar localmente (Offline Cache)
      await _service.agregarTraduccion(nueva);
      
      // Sincronizar con Supabase (Nube)
      _enviarASupabase(textoLimpio, traduccionTexto);

      await _cargarDatos();
      await _hablar(traduccionTexto, _idiomaActualDestino);
    } else {
      // 4. FALLBACK: Si no hay internet y no está en SQLite
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Frase no encontrada offline. Conéctate a internet para traducir."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Función para el botón de la interfaz
  Future<void> _traducirBoton() async {
    if (_controller.text.isEmpty) return;
    await _procesarTraduccion(_controller.text);
    _controller.clear();
  }

  // ── HELPER SUPABASE ──
  Future<void> _enviarASupabase(String original, String traducido) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? "usuario_anonimo";
      
      await supabase.from('traducciones').insert({
        'user_id': userId,
        'texto_original': original,
        'texto_traducido': traducido,
      });
      debugPrint("Sincronizado con Supabase");
    } catch (e) {
      debugPrint("Fallo conexión Supabase (Probablemente offline): $e");
    }
  }

  void _swapIdiomas() {
    setState(() {
      final temp = _idiomaActualOrigen;
      _idiomaActualOrigen = _idiomaActualDestino;
      _idiomaActualDestino = temp;
      _resultadoTraduccion = "";
      _controller.clear();
    });
  }

  // ── HELPERS UI ──
  String get _nombreOrigen => _idiomaActualOrigen == "es" ? "Español" : "Kreyòl";
  String get _nombreDestino => _idiomaActualDestino == "es" ? "Español" : "Kreyòl";
  String get _flagOrigen => _idiomaActualOrigen == "es" ? "🇲🇽" : "🇭🇹";
  String get _flagDestino => _idiomaActualDestino == "es" ? "🇲🇽" : "🇭🇹";
  String get _placeholderText => _idiomaActualOrigen == "es" ? "Escribe en español…" : "Ekri an kreyòl…";
  String get _traducirBtnTxt => _idiomaActualOrigen == "es" ? "Traducir →" : "Tradui →";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111318) : const Color(0xFFF5F3EF);
    final surface = isDark ? const Color(0xFF1E2230) : Colors.white;
    final border = isDark ? const Color(0xFF2D3348) : const Color(0xFFE2DED6);
    final text = isDark ? const Color(0xFFF0EDE8) : const Color(0xFF1C1917);
    final text2 = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF57534E);
    final text3 = isDark ? const Color(0xFF6B7280) : const Color(0xFFA8A29E);
    final blue = const Color(0xFF2563EB);
    final green = isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Container(
            color: surface,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              left: 16, right: 16, bottom: 14,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: text),
                          children: [
                            const TextSpan(text: 'Proyecto '),
                            TextSpan(text: 'Criollo', style: TextStyle(color: blue)),
                          ],
                        ),
                      ),
                    ),
                    _toolBtn(_isListening ? Icons.mic : Icons.mic_none, _listen, border, _isListening ? Colors.red.withOpacity(.1) : const Color(0xFFEFF4FF), iconColor: _isListening ? Colors.red : blue),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _idiomaBadge(_flagOrigen, _nombreOrigen, _idiomaActualOrigen == "es" ? "México" : "Ayisyen", text, text3, blue),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: _swapIdiomas,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: surface, shape: BoxShape.circle, border: Border.all(color: border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8)]),
                          child: Center(child: Text('⇄', style: TextStyle(fontSize: 16, color: blue, fontWeight: FontWeight.w700))),
                        ),
                      ),
                    ),
                    _idiomaBadge(_flagDestino, _nombreDestino, _idiomaActualDestino == "es" ? "México" : "Ayisyen", text, text3, blue),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _card(border: border, surface: surface, child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(hintText: _placeholderText, hintStyle: TextStyle(color: text3), border: InputBorder.none, contentPadding: const EdgeInsets.all(14)),
                        style: TextStyle(fontSize: 17, color: text),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text('${_controller.text.length}/1000', style: TextStyle(fontSize: 11, color: text3)),
                            const Spacer(),
                            GestureDetector(
                              onTap: _traducirBoton,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(100)),
                                child: Text(_traducirBtnTxt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 12),
                  _card(border: border, surface: surface, child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: _traduciendo ? _loadingDots() : Text(
                          _resultadoTraduccion.isNotEmpty ? _resultadoTraduccion : "Traducción...",
                          style: TextStyle(fontSize: 17, color: _resultadoTraduccion.isNotEmpty ? green : text3),
                        ),
                      ),
                      if (_resultadoTraduccion.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _toolBtn(Icons.copy, () => Clipboard.setData(ClipboardData(text: _resultadoTraduccion)), border, bg),
                            const SizedBox(width: 8),
                            _toolBtn(Icons.volume_up, () => _hablar(_resultadoTraduccion, _idiomaActualDestino), border, bg),
                            const SizedBox(width: 12, height: 50),
                          ],
                        ),
                    ],
                  )),
                  if (_spokenText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Escuchando: $_spokenText", style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idiomaBadge(String flag, String name, String sub, Color txt, Color txt3, Color blue) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFEFF4FF), border: Border.all(color: blue), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: txt)),
            Text(sub, style: TextStyle(fontSize: 10, color: txt3)),
          ])
        ]),
      ),
    );
  }

  Widget _card({required Widget child, required Color border, required Color surface}) {
    return Container(decoration: BoxDecoration(color: surface, border: Border.all(color: border), borderRadius: BorderRadius.circular(18)), child: child);
  }

  Widget _toolBtn(IconData icon, VoidCallback onTap, Color border, Color bg, {Color? iconColor}) {
    return GestureDetector(onTap: onTap, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: iconColor)));
  }

  Widget _loadingDots() {
    return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}