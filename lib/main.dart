import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart'; // Asegúrate de que el nombre sea exacto

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase y el archivo .env una sola vez
  await Firebase.initializeApp(); 
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traductor Criollo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          primary: const Color(0xFF2196F3),
        ),
      ),
      // Aquí usamos la L mayúscula para que coincida con tu archivo
      home: const LoginScreen(), 
    );
  }
}