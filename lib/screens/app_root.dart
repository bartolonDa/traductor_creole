import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'phrases_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _isDark = false;

  void toggleTheme(bool val) => setState(() => _isDark = val);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto Criollo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        scaffoldBackgroundColor: const Color(0xFFF5F3EF),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF111318),
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainShell(isDark: _isDark, onThemeToggle: toggleTheme),
    );
  }
}

class MainShell extends StatefulWidget {
  final bool isDark;
  final Function(bool) onThemeToggle;

  const MainShell({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1E2230) : Colors.white;
    final border = isDark ? const Color(0xFF2D3348) : const Color(0xFFE2DED6);
    const selected = Color(0xFF2563EB);
    final unselected = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFFA8A29E);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const PhrasesScreen(),
          const HistoryScreen(),
          ProfileScreen(
            isDark: widget.isDark,
            onThemeToggle: widget.onThemeToggle,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _navItem(
                  0,
                  Icons.translate_rounded,
                  'Traducir',
                  selected,
                  unselected,
                ),
                _navItem(
                  1,
                  Icons.chat_bubble_outline_rounded,
                  'Frases',
                  selected,
                  unselected,
                ),
                _navItem(
                  2,
                  Icons.history_rounded,
                  'Historial',
                  selected,
                  unselected,
                ),
                _navItem(
                  3,
                  Icons.person_outline_rounded,
                  'Perfil',
                  selected,
                  unselected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    Color selected,
    Color unselected,
  ) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });

          if (index == 2) {
            // historial
            HistoryScreenStateNotifier.reload?.call();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isActive ? selected : unselected),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? selected : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
