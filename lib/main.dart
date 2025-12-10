// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/adapters/duration_adapter.dart';
import 'data/models/task.dart'; 
import 'features/main_wrapper.dart';
import 'features/settings/application/theme_provider.dart'; // <== NOUVELLE IMPORTATION

Future<void> initDependencies() async {
  await Hive.initFlutter();

  // Enregistrement des adaptateurs
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ThemeModeAdapter()); // <== ENREGISTREMENT

  // Ouverture des box
  await Hive.openBox<Task>('tasksBox');
  await Hive.openBox('settings'); // <== OUVERTURE

  await NotificationService().init();
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initDependencies();
  runApp(const ProviderScope(child: TodoWorkSessionsApp()));
}

// On transforme en ConsumerWidget pour lire le thème
class TodoWorkSessionsApp extends ConsumerWidget {
  const TodoWorkSessionsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le provider du thème
    final themeMode = ref.watch(themeNotifierProvider);

    FlutterNativeSplash.remove();

    return MaterialApp(
      title: 'Todo Work Sessions',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Votre thème clair existant
      darkTheme: AppTheme.darkTheme,  // On va créer ce thème
      themeMode: themeMode, // On applique le mode choisi
      home: const MainWrapper(), 
    );
  }
}
