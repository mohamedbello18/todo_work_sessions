import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Synchronisation')),
      body: const Center(
        child: Text('Écran pour la connexion/inscription MySQL', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}