import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/traduccion.dart';
import '../services/traduccion_service.dart';
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  // Recibimos el estado del modo offline desde el AppRoot o Perfil
  final bool modoOfflineForzado;

  const HomeScreen({super.key, this.modoOfflineForzado = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final TraduccionService _service = TraduccionService();
  
  List<Traduccion> _lista = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";
  late FlutterTts _tts;

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

  Future<void> _cargarDatos() async {
    final data = await _service.obtenerTraducciones();
    setState(() => _lista = data);
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _idiomaActualOrigen == "es" ? "es_MX" : "fr_FR",
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
              _controller.text = _spokenText;
            });
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

  Future<void> _hablar(String texto, String idioma) async {
    if (idioma == "es") {
      await _tts.setLanguage("es-MX");
    } else {
      await _tts.setLanguage("fr-FR");
    }
    await _tts.speak(texto);
  }

  // ── LÓGICA DE TRADUCCIÓN CON CONTROL OFFLINE ──
  Future<void> _procesarTraduccion(String texto) async {
    final textoLimpio = texto.trim().toLowerCase().replaceAll('.', ''); 
    if (textoLimpio.isEmpty) return;

    setState(() => _traduciendo = true);

    // 1. SIEMPRE BUSCAMOS PRIMERO EN LOCAL
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

    // 2. SI NO ESTÁ EN LOCAL Y EL MODO OFFLINE ESTÁ ACTIVO, BLOQUEAMOS LA API
    if (widget.modoOfflineForzado) {
      setState(() => _traduciendo = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Frase no disponible en modo sin conexión."),
          backgroundColor: Colors.orange,
        ),
      );
      return; 
    }

    // 3. SI EL MODO OFFLINE ESTÁ APAGADO, USAMOS LA API
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

      await _service.agregarTraduccion(nueva);
      _enviarASupabase(textoLimpio, traduccionTexto);
      await _cargarDatos();
      await _hablar(traduccionTexto, _idiomaActualDestino);
    }
  }

  Future<void> _traducirBoton() async {
    if (_controller.text.isEmpty) return;
    await _procesarTraduccion(_controller.text);
    _controller.clear();
  }

  Future<void> _enviarASupabase(String original, String traducido) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? "usuario_anonimo";
      
      // Solo intentamos sincronizar si no estamos forzando modo offline
      if (!widget.modoOfflineForzado) {
        await supabase.from('traducciones').insert({
          'user_id': userId,
          'texto_original': original,
          'texto_traducido': traducido,
        });
      }
    } catch (e) {
      debugPrint("Error Supabase: $e");
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111318) : const Color(0xFFF5F3EF);
    final surface = isDark ? const Color(0xFF1E2230) : Colors.white;
    final border = isDark ? const Color(0xFF2D3348) : const Color(0xFFE2DED6);
    final text = isDark ? const Color(0xFFF0EDE8) : const Color(0xFF1C1917);
    final blue = const Color(0xFF2563EB);
    final green = isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          Container(
            color: surface,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16, right: 16, bottom: 20,
            ),
            child: Column(
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: text),
                      children: [
                        const TextSpan(text: 'Traductor '),
                        TextSpan(text: 'Criollo', style: TextStyle(color: blue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _idiomaBadge(_idiomaActualOrigen == "es" ? "🇲🇽" : "🇭🇹", _idiomaActualOrigen == "es" ? "Español" : "Kreyòl", blue, text),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: _swapIdiomas,
                        child: Icon(Icons.swap_horiz, color: blue, size: 30),
                      ),
                    ),
                    _idiomaBadge(_idiomaActualDestino == "es" ? "🇲🇽" : "🇭🇹", _idiomaActualDestino == "es" ? "Español" : "Kreyòl", blue, text),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(border: border, surface: surface, child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: _idiomaActualOrigen == "es" ? "Escribe aquí..." : "Ekri isit la...",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15)
                        ),
                        style: TextStyle(fontSize: 18, color: text),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            onPressed: _traducirBoton,
                            style: ElevatedButton.styleFrom(backgroundColor: blue, shape: const StadiumBorder()),
                            child: const Text("Traducir", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      )
                    ],
                  )),
                  const SizedBox(height: 20),
                  if (_resultadoTraduccion.isNotEmpty || _traduciendo)
                  _card(border: border, surface: surface, child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: _traduciendo ? const Center(child: CircularProgressIndicator()) : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_resultadoTraduccion, style: TextStyle(fontSize: 20, color: green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(onPressed: () => _hablar(_resultadoTraduccion, _idiomaActualDestino), icon: Icon(Icons.volume_up, color: blue)),
                            IconButton(onPressed: () => Clipboard.setData(ClipboardData(text: _resultadoTraduccion)), icon: Icon(Icons.copy, color: blue)),
                          ],
                        )
                      ],
                    ),
                  )),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: _listen,
                    child: Column(
                      children: [
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.red : blue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening ? Colors.red : blue).withOpacity(0.3),
                                blurRadius: 25, spreadRadius: 5
                              )
                            ],
                          ),
                          child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 45),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _isListening ? "Escuchando..." : "Toca el micro para hablar",
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idiomaBadge(String flag, String name, Color blue, Color txt) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: blue.withOpacity(0.5))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: txt)),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child, required Color border, required Color surface}) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]
      ),
      child: child
    );
  }
}