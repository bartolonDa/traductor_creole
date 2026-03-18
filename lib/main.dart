import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Nuevo
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
// import 'screens/app_root.dart'; // Mantenlo si lo usas más adelante

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargamos las variables de entorno primero
  await dotenv.load(fileName: ".env");

  // 2. Inicializamos Supabase en lugar de Firebase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto Criollo',
      // Mantengo tus colores originales que se ven muy bien
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
      ),
      // Por ahora enviamos a LoginScreen, pero recuerda que 
      // dentro de LoginScreen tendrás que cambiar la lógica de Auth
      home: const LoginScreen(),
    );
  }
}