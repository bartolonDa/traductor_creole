import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
 // Inicializamos Auth0 con las variables del .env
 final Auth0 auth0 = Auth0(
  dotenv.env['AUTH0_DOMAIN']!,
  dotenv.env['AUTH0_CLIENT_ID']!,
 );

 // Reemplaza a signInWithGoogle
 Future<Credentials?> signInWithGoogle() async {
  try {
   // Usamos el scheme sin guion bajo como configuramos en el panel
  final credentials = await auth0
 .webAuthentication(scheme: 'com.example.traductorcreole')
 .login();
 
 return credentials;
 } catch (e) {
 print("Error en AuthService (Auth0): $e");
 return null;
 }
 }

 // Función para cerrar sesión
 Future<void> signOut() async {
 try {
 await auth0
 .webAuthentication(scheme: 'com.example.traductorcreole')
 .logout();
 } catch (e) {
 print("Error al cerrar sesión: $e");
 }
 }

 // Útil para saber si hay un usuario activo
 Future<bool> isLoggedIn() async {
 return await auth0.credentialsManager.hasValidCredentials();
}
} 