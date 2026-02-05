import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/markov_model.dart';
import 'screens/setup_screen.dart';
import 'screens/matrix_screen.dart';
import 'screens/parameters_screen.dart';
import 'screens/result_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MarkovModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markov Chain',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Or dark by default as per screenshots? Screenshots show dark mode mainly but html has class="dark".
      // Let's support both but default to system.
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const SetupScreen(),
      routes: {
        '/setup': (context) => const SetupScreen(),
        '/matrix': (context) => const MatrixScreen(),
        '/parameters': (context) => const ParametersScreen(),
        '/result': (context) => const ResultScreen(),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    // Colors
    final primary = const Color(0xFF137FEC);
    final background = isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8);
    final surface = isDark ? const Color(0xFF1C2127) : const Color(0xFFFFFFFF);
    final onBackground = isDark ? Colors.white : const Color(0xFF0F172A);
    final onSurface = isDark ? Colors.white : const Color(0xFF0F172A);
    
    // Font
    final textTheme = GoogleFonts.spaceGroteskTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: surface,
        onSurface: onSurface,
        background: background,
        onBackground: onBackground,
        primary: primary,
      ),
      textTheme: textTheme.apply(
        bodyColor: onBackground,
        displayColor: onBackground,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF11161B) : const Color(0xFFF8FAFC), // slightly different for inputs
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3B4754) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF3B4754) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
        ),
      ),
    );
  }
}
