// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:tarot_ai_1/screens/courses_screen.dart';
import 'package:tarot_ai_1/screens/diario_screen.dart';
import 'package:tarot_ai_1/screens/feed_screen.dart';
import 'package:tarot_ai_1/screens/profile_screen.dart';
import 'package:tarot_ai_1/screens/reading_hub_screen.dart'; // 1. Importa il nuovo hub

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 2. Aggiorna la lista dei widget
  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    ReadingHubScreen(), // SOSTITUITO: Ora punta al menu delle letture
    CoursesScreen(),
    DiarioScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_vintage_sharp), // Icona aggiornata per i Tarocchi
            label: 'Lettura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Corsi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}