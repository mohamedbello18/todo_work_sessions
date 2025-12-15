// page/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Bascule entre Connexion et Inscription
  String _email = '';
  String _username = '';
  String _password = '';
  String _confirmPassword = '';

  void _submitAuthForm(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    String message = '';
    bool success = false;

    if (_isLogin) {
      // Tenter la connexion
      success = await auth.signIn(_email, _password);
      message = success ? 'Connexion réussie !' : 'Échec de la connexion. Vérifiez vos identifiants.';
    } else {
      // Tenter l'inscription
      await auth.signUp(_email, _username, _password);
      success = true; // Simulation: l'inscription réussit toujours
      message = 'Inscription réussie et connexion automatique !';
    }

    // Afficher la Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24,
          right: 24
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            Image.asset("asset/logo.png",height: 150,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(_isLogin ? 'Connexion' : 'Créer un nouveau compte',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
            ),
                SizedBox(
                  height: 20,
                ),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: const ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Adresse Email', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Veuillez entrer une adresse email valide.';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!.trim(),
                  ),
                  const SizedBox(height: 12),
            
                  // Champ Nom d'utilisateur (uniquement pour l'inscription)
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey('username'),
                      decoration: const InputDecoration(labelText: 'Nom d\'utilisateur', border: OutlineInputBorder()),
                      validator: (value) {
                        if (!_isLogin && (value == null || value.isEmpty || value.length < 4)) {
                          return 'Le nom d\'utilisateur doit contenir au moins 4 caractères.';
                        }
                        return null;
                      },
                      onSaved: (value) => _username = value!.trim(),
                    ),
                  if (!_isLogin) const SizedBox(height: 12),
            
                  // Champ Mot de passe
                  TextFormField(
                    key: const ValueKey('password'),
                    decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères.';
                      }
                      _password = value; // Stocker pour la confirmation
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 12),
                  
                  // Champ Confirmation de Mot de passe (uniquement pour l'inscription)
                  if (!_isLogin)
                    TextFormField(
                      key: const ValueKey('confirm_password'),
                      decoration: const InputDecoration(labelText: 'Confirmer Mot de passe', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) {
                        if (!_isLogin && value != _password) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                      onSaved: (value) => _confirmPassword = value!,
                    ),
                  if (!_isLogin) const SizedBox(height: 20),
            
                  // Bouton Soumettre
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : () => _submitAuthForm(context, auth),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isLogin ? 'Se Connecter' : 'S\'inscrire'),
                    ),
                  ),
                  const SizedBox(height: 10),
            
                  // Bascule Connexion/Inscription
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState!.reset(); // Réinitialiser le formulaire lors du changement
                      });
                    },
                    child: Text(_isLogin
                        ? 'Pas de compte ? Créer un compte'
                        : 'J\'ai déjà un compte ? Me connecter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}