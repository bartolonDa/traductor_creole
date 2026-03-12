import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'app_root.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── TU LÓGICA ORIGINAL DE GOOGLE (sin cambios) ──
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final user = await AuthService().signInWithGoogle();

    setState(() => _isLoading = false);

    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AppRoot()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo iniciar sesión con Google. Revisa tu conexión."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ── LOGIN CON EMAIL (igual que antes) ──
  void _handleEmailLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AppRoot()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF2FF),
              Color(0xFFF5F3EF),
              Color(0xFFFEF9F0),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ── LOGO ANIMADO ──
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _floatAnim.value),
                    child: child,
                  ),
                  child: SizedBox(
                    width: 200,
                    height: 115,
                    child: CustomPaint(painter: _LogoPainter()),
                  ),
                ),

                const SizedBox(height: 16),

                // ── TÍTULO ──
                const Text(
                  'Proyecto Criollo',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1917),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Inclusión a través de la comunicación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF57534E),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // ── CAMPO EMAIL ──
                _buildField(
                  controller: _emailController,
                  hint: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // ── CAMPO CONTRASEÑA ──
                _buildField(
                  controller: _passwordController,
                  hint: 'Contraseña',
                  obscure: true,
                ),

                // ── OLVIDASTE CONTRASEÑA ──
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 14),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── BOTÓN INICIAR SESIÓN ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleEmailLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── DIVISOR ──
                const Row(children: [
                  Expanded(child: Divider(color: Color(0xFFE2DED6))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'O continúa con',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA8A29E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE2DED6))),
                ]),

                const SizedBox(height: 16),

                // ── BOTÓN GOOGLE — TU LÓGICA ORIGINAL INTACTA ──
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFE2DED6),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Tu imagen local que ya tienes en assets
                              Image.asset(
                                'assets/images/google_logo.png',
                                height: 22,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continuar con Google',
                                style: TextStyle(
                                  color: Color(0xFF1C1917),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                const SizedBox(height: 22),

                // ── REGISTRO ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(fontSize: 13, color: Color(0xFFA8A29E)),
                    ),
                    GestureDetector(
                      onTap: _handleGoogleLogin,
                      child: const Text(
                        'Regístrate gratis',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2DED6), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFA8A29E),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1C1917),
        ),
      ),
    );
  }
}

// ════════════════════════════════════
// LOGO — Infinito con manos entrelazadas
// ════════════════════════════════════
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.075
      ..strokeCap = StrokeCap.round;

    // C izquierda — Haití azul
    paint.color = const Color(0xFF1B3A8C);
    final leftC = Path()
      ..moveTo(w * 0.40, h * 0.07)
      ..cubicTo(w * 0.25, h * 0.07, w * 0.11, h * 0.22, w * 0.06, h * 0.43)
      ..cubicTo(w * 0.03, h * 0.55, w * 0.05, h * 0.70, w * 0.14, h * 0.82)
      ..cubicTo(w * 0.22, h * 0.93, w * 0.34, h * 1.00, w * 0.40, h * 1.00)
      ..lineTo(w * 0.40, h * 0.88)
      ..cubicTo(w * 0.33, h * 0.85, w * 0.24, h * 0.78, w * 0.20, h * 0.68)
      ..cubicTo(w * 0.15, h * 0.56, w * 0.15, h * 0.44, w * 0.20, h * 0.34)
      ..cubicTo(w * 0.25, h * 0.23, w * 0.33, h * 0.17, w * 0.40, h * 0.17)
      ..close();
    canvas.drawPath(leftC, paint);

    // Arco rojo Haití
    paint.color = const Color(0xFFCE1126);
    final redArc = Path()
      ..moveTo(w * 0.40, h * 0.07)
      ..lineTo(w * 0.40, h * 0.17)
      ..cubicTo(w * 0.34, h * 0.17, w * 0.28, h * 0.20, w * 0.23, h * 0.25)
      ..lineTo(w * 0.17, h * 0.12)
      ..cubicTo(w * 0.23, h * 0.08, w * 0.31, h * 0.07, w * 0.40, h * 0.07)
      ..close();
    canvas.drawPath(redArc, paint);

    // C derecha — Verde Latam
    paint.color = const Color(0xFF1A7A3A);
    final rightC = Path()
      ..moveTo(w * 0.60, h * 0.07)
      ..cubicTo(w * 0.75, h * 0.07, w * 0.89, h * 0.22, w * 0.94, h * 0.43)
      ..cubicTo(w * 0.97, h * 0.55, w * 0.95, h * 0.70, w * 0.86, h * 0.82)
      ..cubicTo(w * 0.78, h * 0.93, w * 0.66, h * 1.00, w * 0.60, h * 1.00)
      ..lineTo(w * 0.60, h * 0.88)
      ..cubicTo(w * 0.67, h * 0.85, w * 0.76, h * 0.78, w * 0.80, h * 0.68)
      ..cubicTo(w * 0.85, h * 0.56, w * 0.85, h * 0.44, w * 0.80, h * 0.34)
      ..cubicTo(w * 0.75, h * 0.23, w * 0.67, h * 0.17, w * 0.60, h * 0.17)
      ..close();
    canvas.drawPath(rightC, paint);

    // Arco dorado
    paint.color = const Color(0xFFD4820A);
    final goldArc = Path()
      ..moveTo(w * 0.60, h * 0.07)
      ..lineTo(w * 0.60, h * 0.17)
      ..cubicTo(w * 0.66, h * 0.17, w * 0.72, h * 0.20, w * 0.77, h * 0.25)
      ..lineTo(w * 0.83, h * 0.12)
      ..cubicTo(w * 0.77, h * 0.08, w * 0.69, h * 0.07, w * 0.60, h * 0.07)
      ..close();
    canvas.drawPath(goldArc, paint);

    // Franja negra
    paint.color = const Color(0xFF111111);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.60, h * 0.45, w * 0.28, h * 0.14), paint);

    // Arco rojo inferior
    paint.color = const Color(0xFFC0392B);
    final redBottom = Path()
      ..moveTo(w * 0.60, h * 1.00)
      ..lineTo(w * 0.60, h * 0.88)
      ..cubicTo(w * 0.66, h * 0.85, w * 0.72, h * 0.82, w * 0.77, h * 0.77)
      ..lineTo(w * 0.83, h * 0.90)
      ..cubicTo(w * 0.77, h * 0.96, w * 0.69, h * 1.00, w * 0.60, h * 1.00)
      ..close();
    canvas.drawPath(redBottom, paint);

    // Conectores del infinito
    strokePaint.color = const Color(0xFF1A7A3A);
    canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.00, w * 0.44, h * 0.35),
        3.14, 3.14, false, strokePaint);
    strokePaint.color = const Color(0xFFCE1126);
    canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.70, w * 0.44, h * 0.35),
        0, 3.14, false, strokePaint);

    // Manos entrelazadas
    paint.color = const Color(0xFF6B3E26);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.30, h * 0.42, w * 0.22, h * 0.18),
            const Radius.circular(8)),
        paint);
    paint.color = const Color(0xFFC4956A);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.48, h * 0.42, w * 0.22, h * 0.18),
            const Radius.circular(8)),
        paint);
    paint.color = const Color(0xFF7A4F32);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.38, h * 0.42, w * 0.24, h * 0.18),
            const Radius.circular(8)),
        paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
