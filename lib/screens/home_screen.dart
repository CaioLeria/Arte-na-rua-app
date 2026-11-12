import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'accessibility_screen.dart';
import 'artwork_list_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  static const List<String> titles = [
    'Obras',
    'Favoritos',
    'Acessibilidade',
    'Sobre',
  ];

  // Cada troca de aba recria a tela.
  Widget buildScreen() {
    switch (currentIndex) {
      case 0:
        return const ArtworkListScreen();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const AccessibilityScreen();
      default:
        return const AboutScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[currentIndex])),
      body: buildScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: 'Obras'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new), label: 'Acessibilidade'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Sobre'),
        ],
      ),
    );
  }
}
