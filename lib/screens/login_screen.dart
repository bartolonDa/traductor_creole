import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Importamos tu lógica de Firebase
import 'home_screen.dart'; // Navegación al traductor

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para el login manual (opcional si solo usas Google)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Función principal para el inicio de sesión con Google
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    final user = await AuthService().signInWithGoogle(); // Llamada al servicio configurado
    
    setState(() => _isLoading = false);

    if (user != null) {
      if (!mounted) return;
      // Navegamos al Home (Traductor) y eliminamos la pila de navegación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      if (!mounted) return;
      // Mostramos error si algo falla con Firebase/Google
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo iniciar sesión con Google. Revisa tu conexión."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // SingleChildScrollView evita que el teclado rompa el diseño (error de overflow)
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo e Identidad del Proyecto Criollo
              const Icon(Icons.translate, size: 80, color: Color(0xFF2196F3)),
              const SizedBox(height: 20),
              const Text(
                "Proyecto Criollo",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Text(
                "Inclusión a través de la comunicación",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // Campo de Correo
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de Iniciar Sesión Tradicional
              ElevatedButton(
                onPressed: () {
                  // Simulación por ahora
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 20),
              const Text("O continúa con", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // BOTÓN DE GOOGLE CORREGIDO (Sin errores de red o tamaño)
              _isLoading 
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: _handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Color(0xFFDADCE0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Usamos el asset local que configuramos en el pubspec
                        Image.asset(
                          'assets/images/google_logo.png',
                          height: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Continuar con Google",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}