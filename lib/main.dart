// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// **CRITIQUE : Import pour la locale**
import 'package:intl/date_symbol_data_local.dart'; 
// **CRITIQUE : Import pour les délégués**
import 'package:flutter_localizations/flutter_localizations.dart'; 

import 'providers/todo_list_provider.dart';
import 'providers/auth_provider.dart';
import 'page/splash_screen.dart'; 

// La fonction main doit être asynchrone (async)
void main() async {
  // 1. Doit être appelé avant initializeDateFormatting
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Initialisation des données de formatage pour la locale 'fr'
  // Le 'await' garantit que l'opération est finie avant runApp()
  await initializeDateFormatting('fr', null); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoListProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()), 
      ],
      child: MaterialApp(
        title: 'Todo App Avancée',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        
        // 3. Configuration des délégués de localisation (CRITIQUE)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 4. Déclare les locales supportées
        supportedLocales: const [
          Locale('fr', 'FR'), 
          Locale('en', 'US'), 
        ],
        
        // Lancement du SplashScreen en premier
        home: const SplashScreen(), 
      ),
    );
  }
}