// page/parametre.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class Parametre extends StatefulWidget {
  const Parametre({super.key});

  @override
  State<Parametre> createState() => _ParametreState();
}

class _ParametreState extends State<Parametre> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _usernameController = TextEditingController(text: currentUser?.username ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  void _submitUpdate(AuthProvider auth) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final newUsername = _usernameController.text;
      final newEmail = _emailController.text;
      
      await auth.updateUserInfo(newUsername, newEmail);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations du compte mises à jour !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final currentUser = auth.currentUser;
        
        if (currentUser == null) {
          return const Center(child: Text("Erreur: Utilisateur non connecté."));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Paramètres du Compte',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600)),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Informations du Compte',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Champ Nom d'utilisateur
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Nom d\'utilisateur', prefixIcon: Icon(Icons.person)),
                        enabled: !auth.isLoading, // Désactiver pendant le chargement
                        validator: (value) {
                           if (value == null || value.isEmpty || value.length < 4) {
                            return 'Minimum 4 caractères.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Champ Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                        enabled: !auth.isLoading, // Désactiver pendant le chargement
                        validator: (value) {
                           if (value == null || !value.contains('@')) {
                            return 'Email invalide.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Bouton Enregistrer les modifications
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: auth.isLoading ? null : () => _submitUpdate(auth),
                          icon: auth.isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save),
                          label: Text(auth.isLoading ? 'Enregistrement...' : 'Enregistrer les modifications'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                const Text(
                  'Sécurité et Connexion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      auth.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Déconnexion réussie !'))
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Se Déconnecter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}