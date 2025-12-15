// providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // --- Fonctions SIMULÉES ---

  // Simule une inscription
  Future<void> signUp(String email, String username, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1)); // Simule le temps de réseau

    // Simule la création d'un utilisateur et la connexion
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID unique simulé
      username: username,
      email: email,
    );
    _setLoading(false);
    notifyListeners();
  }

  // Simule une connexion
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    await Future.delayed(const Duration(seconds: 1)); 

    // Simulation : si l'email n'est pas "fail", on connecte un utilisateur
    if (email.contains("fail")) {
      _setLoading(false);
      return false; // Échec de la connexion
    }

    _currentUser = User(
      id: 'mock_user_1',
      username: 'UtilisateurMock',
      email: email,
    );
    _setLoading(false);
    notifyListeners();
    return true; // Succès de la connexion
  }

  // Déconnexion
  void signOut() {
    _currentUser = null;
    notifyListeners();
  }

  // Mise à jour des informations utilisateur
  Future<void> updateUserInfo(String newUsername, String newEmail) async {
    if (_currentUser == null) return;

    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 500)); 

    _currentUser = _currentUser!.copyWith(
      username: newUsername,
      email: newEmail,
    );
    
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}