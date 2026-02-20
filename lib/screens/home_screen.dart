import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);
    _cargarDatos();
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
            });
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
            idiomaOrigen: "ES",
            idiomaDestino: "HT",
            fecha: DateTime.now().toString(),
          );

          await _service.agregarTraduccion(nueva);
          await _cargarDatos();
          await _hablar(traduccionTexto, _idiomaActualDestino);
          setState(() {
            _spokenText = "";
          });
        }
      }
    }
  }

  Future<void> _hablar(String texto, String idioma) async {
    if (idioma == "es") {
      await _tts.setLanguage("es-MX");
    } else {
      await _tts.setLanguage("fr-FR"); // puede variar según dispositivo
    }

    await _tts.speak(texto);
  }

  Future<void> _cargarDatos() async {
    final data = await _service.obtenerTraducciones();
    setState(() {
      _lista = data;
    });
  }

  Future<void> _traducirYGuardar() async {
    if (_controller.text.isEmpty) return;

    final traduccionTexto = await _api.traducirTexto(
      texto: _controller.text,
      source: _idiomaActualOrigen,
      target: _idiomaActualDestino,
    );

    if (traduccionTexto != null) {
      final nueva = Traduccion(
        textoOriginal: _controller.text,
        textoTraducido: traduccionTexto,
        idiomaOrigen: "ES",
        idiomaDestino: "HT",
        fecha: DateTime.now().toString(),
      );
      await _service.agregarTraduccion(nueva);
      await _cargarDatos();
      _controller.clear();
      await _hablar(traduccionTexto, _idiomaActualDestino);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traductor Creole")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_idiomaActualOrigen.toUpperCase()),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {
                  setState(() {
                    final temp = _idiomaActualOrigen;
                    _idiomaActualOrigen = _idiomaActualDestino;
                    _idiomaActualDestino = temp;
                  });
                },
              ),
              Text(_idiomaActualDestino.toUpperCase()),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Escribe algo",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _traducirYGuardar,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          if (_spokenText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Escuchando: $_spokenText",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _lista.length,
              itemBuilder: (context, index) {
                final item = _lista[index];
                return ListTile(
                  title: Text(item.textoOriginal),
                  subtitle: Text(item.textoTraducido),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isListening ? Colors.red : Colors.blue,
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
