import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/coin_flip_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system status bar & navigation bar to transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CoinFlipApp());
}

class CoinFlipApp extends StatefulWidget {
  const CoinFlipApp({super.key});

  @override
  State<CoinFlipApp> createState() => _CoinFlipAppState();
}

class _CoinFlipAppState extends State<CoinFlipApp> {
  bool _isDark = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDark = isDark;
    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coin Flip - Dafi Al Fajar',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFD6E6F5),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF161E28),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: CoinFlipScreen(
        isDark: _isDark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}
