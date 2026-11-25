import 'package:flutter/material.dart';

import 'features/speech_to_text/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NepaliSathiApp());
}

class NepaliSathiApp extends StatelessWidget {
  const NepaliSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nepali Sathi',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16845B),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}