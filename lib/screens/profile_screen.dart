import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDark;
  final Function(bool) onThemeToggle;

  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _audio = true;
  bool _offline = true;
  bool _saveHist = true;

  // 1. Declaramos la variable del usuario y el cliente
  User? _currentUser;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // 2. Cargamos el usuario actual al iniciar
    _currentUser = _supabase.auth.currentUser;

    // ESCÁNER PARA LA TERMINAL
    debugPrint("=== ESCÁNER DE INICIO ===");
    debugPrint("ID: ${_currentUser?.id}");
    debugPrint("Email: ${_currentUser?.email}");
    debugPrint("Metadata: ${_currentUser?.userMetadata}");

    // 3. Escuchamos cambios de sesión en tiempo real
    _supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _currentUser = data.session?.user;
        });
        debugPrint("=== CAMBIO DE AUTH DETECTADO ===");
        debugPrint("Nuevo Usuario: ${_currentUser?.email}");
      }
    });
  }

  // ── FUNCIÓN DE CIERRE DE SESIÓN SEGURO ──
  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await AuthService().signOut();
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        debugPrint("Error al cerrar sesión: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Búsqueda exhaustiva en metadatos (Google usa varias llaves)
    final bool isGuest = _currentUser == null;
    
    final String userName = _currentUser?.userMetadata?['full_name'] ?? 
                           _currentUser?.userMetadata?['name'] ?? 
                           "Usuario Invitado";
    
    final String? userPhoto = _currentUser?.userMetadata?['avatar_url'] ?? 
                             _currentUser?.userMetadata?['picture'];

    final isDark = widget.isDark;
    final bg = isDark ? const Color(0xFF111318) : const Color(0xFFF5F3EF);
    final surface = isDark ? const Color(0xFF1E2230) : Colors.white;
    final border = isDark ? const Color(0xFF2D3348) : const Color(0xFFE2DED6);
    final text = isDark ? const Color(0xFFF0EDE8) : const Color(0xFF1C1917);
    final text3 = isDark ? const Color(0xFF6B7280) : const Color(0xFFA8A29E);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HERO AZUL ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 28, left: 22, right: 22,
              ),
              child: Column(
                children: [
                  Container(
                    width: 85, height: 85,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(.3), width: 3),
                    ),
                    child: Center(
                      child: isGuest || userPhoto == null
                          ? const Text('👤', style: TextStyle(fontSize: 45))
                          : ClipOval(child: Image.network(
                              userPhoto, 
                              fit: BoxFit.cover, 
                              errorBuilder: (context, error, stackTrace) => const Text('👤', style: TextStyle(fontSize: 45))
                            )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isGuest ? 'Modo Invitado' : '✦ Miembro activo',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(.85)),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('APARIENCIA', text3),
                  _settingToggle(
                    icon: Icons.dark_mode_rounded,
                    iconBg: isDark ? const Color(0xFF2A2A3E) : const Color(0xFF1A1A2E),
                    iconColor: Colors.white,
                    title: 'Modo oscuro',
                    subtitle: isDark ? 'Activado' : 'Desactivado',
                    value: isDark,
                    onChanged: widget.onThemeToggle,
                    surface: surface, border: border, text: text, text3: text3,
                  ),
                  _sectionLabel('FUNCIONES', text3),
                  _settingToggle(
                    icon: Icons.volume_up_rounded,
                    iconBg: isDark ? const Color(0xFF1C1A10) : const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: 'Pronunciación automática',
                    subtitle: _audio ? 'Activo' : 'Desactivado',
                    value: _audio,
                    onChanged: (v) => setState(() => _audio = v),
                    surface: surface, border: border, text: text, text3: text3,
                  ),
                  const SizedBox(height: 8),
                  _settingToggle(
                    icon: Icons.wifi_off_rounded,
                    iconBg: const Color(0xFFEFF4FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Modo sin conexión',
                    subtitle: _offline ? 'Activo (Solo local)' : 'Desactivado (Usa API)',
                    value: _offline,
                    onChanged: (v) => setState(() => _offline = v),
                    surface: surface, border: border, text: text, text3: text3,
                  ),
                  const SizedBox(height: 8),
                  _settingToggle(
                    icon: Icons.save_outlined,
                    iconBg: isDark ? const Color(0xFF1A1D24) : const Color(0xFFECEAE5),
                    iconColor: text3,
                    title: 'Guardar historial',
                    subtitle: _saveHist ? 'Activo' : 'Desactivado',
                    value: _saveHist,
                    onChanged: (v) => setState(() => _saveHist = v),
                    surface: surface, border: border, text: text, text3: text3,
                  ),
                  _sectionLabel('CUENTA', text3),
                  _settingRow(
                    icon: Icons.person_outline_rounded,
                    iconBg: const Color(0xFFEFF4FF),
                    iconColor: const Color(0xFF2563EB),
                    title: 'Editar perfil',
                    sub: isGuest ? 'No disponible como invitado' : 'Nombre y foto',
                    surface: surface, border: border, text: text, text3: text3,
                  ),
                  const SizedBox(height: 8),
                  _settingRow(
                    icon: Icons.info_outline_rounded,
                    iconBg: isDark ? const Color(0xFF1A1D24) : const Color(0xFFECEAE5),
                    iconColor: text3,
                    title: 'Versión',
                    sub: '1.0.0 Beta · Android',
                    surface: surface, border: border, text: text, text3: text3,
                    showChevron: false,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D1010) : const Color(0xFFFEF2F2),
                        border: Border.all(color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5), width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 18, color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C)),
                          const SizedBox(width: 8),
                          Text(isGuest ? 'Volver al inicio' : 'Cerrar sesión',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2, color: color)),
    );
  }

  Widget _settingRow({required IconData icon, required Color iconBg, required Color iconColor, required String title, required String sub, required Color surface, required Color border, required Color text, required Color text3, bool showChevron = true}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: surface, border: Border.all(color: border), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 18, color: iconColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
          Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text3)),
        ])),
        if (showChevron) Icon(Icons.chevron_right_rounded, color: text3, size: 20),
      ]),
    );
  }

  Widget _settingToggle({required IconData icon, required Color iconBg, required Color iconColor, required String title, required String subtitle, required bool value, required Function(bool) onChanged, required Color surface, required Color border, required Color text, required Color text3}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: surface, border: Border.all(color: border), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 18, color: iconColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
          Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text3)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF2563EB)),
      ]),
    );
  }
}