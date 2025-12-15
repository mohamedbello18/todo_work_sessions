// page/MainPage.dart (Mise à jour pour l'authentification)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart'; // NOUVEL IMPORT
import 'accueil.dart';
import 'session.dart';
import 'parametre.dart';
import 'auth_screen.dart'; // NOUVEL IMPORT

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  // Liste des pages de l'application principale
  final List<Widget> _pages = const [
    Accueil(),
    Session(),
    Parametre(),
  ];

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écoute l'état d'authentification
    final authProvider = Provider.of<AuthProvider>(context);

    // Si l'utilisateur n'est PAS connecté, afficher l'écran d'authentification
    if (!authProvider.isAuthenticated) {
      return const AuthScreen();
    }
    
    // Si l'utilisateur est connecté, afficher la navigation principale
    return Scaffold(
      body: _pages[_currentIndex], 
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Session',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètre',
          ),
        ],
      ),
    );
  }
}