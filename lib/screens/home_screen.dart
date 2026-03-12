import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/traduccion.dart';
import '../services/traduccion_service.dart';
import '../services/api_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── TUS SERVICIOS ORIGINALES (sin cambios) ──
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

  // ── NUEVO: resultado de traducción visible ──
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

  // ── TUS FUNCIONES ORIGINALES (sin cambios) ──
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
        final traduccionTexto = await _api.traducirTexto(
          texto: _spokenText,
          source: _idiomaActualOrigen,
          target: _idiomaActualDestino,
        );
        if (traduccionTexto != null) {
          final nueva = Traduccion(
            textoOriginal: _spokenText,
            textoTraducido: traduccionTexto,
            idiomaOrigen: _idiomaActualOrigen.toUpperCase(),
            idiomaDestino: _idiomaActualDestino.toUpperCase(),
            fecha: DateTime.now().toString(),
          );
          await _service.agregarTraduccion(nueva);
          await _cargarDatos();
          await _hablar(traduccionTexto, _idiomaActualDestino);
          setState(() {
            _spokenText = "";
            _resultadoTraduccion = traduccionTexto;
          });
        }
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

  Future<void> _cargarDatos() async {
    final data = await _service.obtenerTraducciones();
    setState(() => _lista = data);
  }

  Future<void> _traducirYGuardar() async {
    if (_controller.text.isEmpty) return;
    final textoOriginal = _controller.text;

    setState(() => _traduciendo = true);

    final traduccionTexto = await _api.traducirTexto(
      texto: textoOriginal,
      source: _idiomaActualOrigen,
      target: _idiomaActualDestino,
    );

    setState(() => _traduciendo = false);

    if (traduccionTexto != null) {
      setState(() => _resultadoTraduccion = traduccionTexto);

      final nueva = Traduccion(
        textoOriginal: textoOriginal,
        textoTraducido: traduccionTexto,
        idiomaOrigen: _idiomaActualOrigen.toUpperCase(),
        idiomaDestino: _idiomaActualDestino.toUpperCase(),
        fecha: DateTime.now().toString(),
      );
      await _service.agregarTraduccion(nueva);
      await _cargarDatos();
      _controller.clear();
      await _hablar(traduccionTexto, _idiomaActualDestino);
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
  String get _placeholderText => _idiomaActualOrigen == "es"
      ? "Escribe en español…"
      : "Ekri an kreyòl…";
  String get _traducirBtnTxt => _idiomaActualOrigen == "es"
      ? "Traducir →"
      : "Tradui →";

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
          // ── TOP BAR ──
          Container(
            color: surface,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 4,
              left: 16, right: 16, bottom: 14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: text,
                          ),
                          children: [
                            const TextSpan(text: 'Proyecto '),
                            TextSpan(
                              text: 'Criollo',
                              style: TextStyle(color: blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Mic button in header
                    GestureDetector(
                      onTap: _listen,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.red.withOpacity(.12)
                              : const Color(0xFFEFF4FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening ? Colors.red : blue.withOpacity(.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 18,
                          color: _isListening ? Colors.red : blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── SELECTOR DE IDIOMA ──
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          border: Border.all(color: blue, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(_flagOrigen,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_nombreOrigen,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: text)),
                                  Text(
                                    _idiomaActualOrigen == "es"
                                        ? "México"
                                        : "Ayisyen",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: text3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _swapIdiomas,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: border, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.06),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text('⇄',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: blue,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          border: Border.all(color: blue, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(_flagDestino,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_nombreDestino,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: text)),
                                  Text(
                                    _idiomaActualDestino == "es"
                                        ? "México"
                                        : "Ayisyen",
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: text3),
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
              ],
            ),
          ),
          Divider(height: 1, color: border),

          // ── CONTENIDO SCROLLABLE ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── CARD INPUT ──
                  _card(
                    border: border, surface: surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                          child: Row(children: [
                            Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                    color: blue, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              _idiomaActualOrigen == "es"
                                  ? "TEXTO EN ESPAÑOL"
                                  : "TÈKS AN KREYÒL",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w800,
                                  letterSpacing: 2, color: text3),
                            ),
                          ]),
                        ),
                        TextField(
                          controller: _controller,
                          maxLines: 4,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: _placeholderText,
                            hintStyle: TextStyle(
                                color: text3,
                                fontWeight: FontWeight.w400,
                                fontSize: 15),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding:
                                const EdgeInsets.fromLTRB(14, 8, 14, 8),
                          ),
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: text),
                        ),
                        Divider(height: 1, color: border),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: Row(children: [
                            Text(
                              '${_controller.text.length} / 1000',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: text3,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            // Limpiar
                            _toolBtn(Icons.close, () {
                              _controller.clear();
                              setState(() => _resultadoTraduccion = "");
                            }, border, bg),
                            const SizedBox(width: 6),
                            // Mic
                            _toolBtn(
                              _isListening ? Icons.mic : Icons.mic_none,
                              _listen, border,
                              _isListening ? Colors.red.withOpacity(.1) : bg,
                              iconColor: _isListening ? Colors.red : null,
                            ),
                            const SizedBox(width: 8),
                            // Traducir
                            GestureDetector(
                              onTap: _traducirYGuardar,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: blue,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: blue.withOpacity(.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Text(
                                  _traducirBtnTxt,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── CARD OUTPUT ──
                  _card(
                    border: border, surface: surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                          child: Row(children: [
                            Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                    color: green, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              _idiomaActualDestino == "es"
                                  ? "TRADUCCIÓN AL ESPAÑOL"
                                  : "TRADIKSYON AN KREYÒL",
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w800,
                                  letterSpacing: 2, color: text3),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                          child: _traduciendo
                              ? _loadingDots()
                              : SizedBox(
                                  width: double.infinity,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        minHeight: 60),
                                    child: Text(
                                      _resultadoTraduccion.isNotEmpty
                                          ? _resultadoTraduccion
                                          : (_idiomaActualDestino == "es"
                                              ? "La traducción aparecerá aquí…"
                                              : "Tradiksyon an pral parèt la a…"),
                                      style: TextStyle(
                                        fontSize: _resultadoTraduccion.isNotEmpty
                                            ? 17
                                            : 15,
                                        fontWeight:
                                            _resultadoTraduccion.isNotEmpty
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                        color: _resultadoTraduccion.isNotEmpty
                                            ? green
                                            : text3,
                                        fontStyle:
                                            _resultadoTraduccion.isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                        height: 1.55,
                                      ),
                                      maxLines: 6,
                                    ),
                                  ),
                                ),
                        ),
                        if (_resultadoTraduccion.isNotEmpty) ...[
                          Divider(height: 1, color: border),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(12, 8, 12, 10),
                            child: Row(children: [
                              const Spacer(),
                              _toolBtn(Icons.copy_outlined, () {
                                Clipboard.setData(ClipboardData(
                                    text: _resultadoTraduccion));
                              }, border, bg),
                              const SizedBox(width: 6),
                              _toolBtn(Icons.volume_up_outlined, () {
                                _hablar(_resultadoTraduccion,
                                    _idiomaActualDestino);
                              }, border, bg),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── ESCUCHANDO ──
                  if (_spokenText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(.08),
                        border: Border.all(
                            color: Colors.red.withOpacity(.3), width: 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        const Icon(Icons.mic, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Escuchando: $_spokenText',
                            style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.red),
                          ),
                        ),
                      ]),
                    ),

                  const SizedBox(height: 16),

                  // ── FRASES MÁS USADAS DEL USUARIO ──
                  if (_lista.isNotEmpty) ...[
                    Text(
                      _idiomaActualOrigen == "es"
                          ? "MIS FRASES FRECUENTES"
                          : "FRAZ MWÈ ITILIZE PLIS",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: text3),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _lista
                          .take(6)
                          .map((item) => GestureDetector(
                                onTap: () {
                                  _controller.text = item.textoOriginal;
                                  setState(() {});
                                  _traducirYGuardar();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    border:
                                        Border.all(color: border, width: 1.5),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    item.textoOriginal.length > 20
                                        ? '${item.textoOriginal.substring(0, 20)}…'
                                        : item.textoOriginal,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: text2),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, required Color border, required Color surface}) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _toolBtn(IconData icon, VoidCallback onTap, Color border, Color bg,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: iconColor ?? const Color(0xFF57534E)),
      ),
    );
  }

  Widget _loadingDots() {
    return SizedBox(
      height: 52,
      child: Row(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + i * 150),
              builder: (_, v, child) =>
                  Transform.translate(offset: Offset(0, -6 * v), child: child),
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF2563EB), shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
