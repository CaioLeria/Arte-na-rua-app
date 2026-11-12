import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const ArteNaRuaApp());
}

class ArteNaRuaApp extends StatefulWidget {
  const ArteNaRuaApp({super.key});

  @override
  State<ArteNaRuaApp> createState() => _ArteNaRuaAppState();
}

class _ArteNaRuaAppState extends State<ArteNaRuaApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArteNaRua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
