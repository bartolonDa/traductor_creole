import 'package:flutter/material.dart';
import '../models/traduccion.dart';
import '../services/traduccion_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TraduccionService _service = TraduccionService();
  List<Traduccion> _lista = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await _service.obtenerTraducciones();
    setState(() {
      _lista = data;
    });
  }

  Future<void> _agregarEjemplo() async {
    final nueva = Traduccion(
      textoOriginal: "Hola",
      textoTraducido: "Bonjou",
      idiomaOrigen: "ES",
      idiomaDestino: "HT",
      fecha: DateTime.now().toString(),
    );

    await _service.agregarTraduccion(nueva);
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traductor Creole")),
      body: ListView.builder(
        itemCount: _lista.length,
        itemBuilder: (context, index) {
          final item = _lista[index];
          return ListTile(
            title: Text(item.textoOriginal),
            subtitle: Text(item.textoTraducido),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarEjemplo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
