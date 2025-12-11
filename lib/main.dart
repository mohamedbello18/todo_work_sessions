// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'data/adapters/duration_adapter.dart';
import 'data/models/session.dart';
import 'data/models/task.dart'; 
import 'features/main_wrapper.dart';
import 'features/settings/application/theme_provider.dart';
import 'pages/splash_screen.dart';

Future<void> initDependencies() async {
  await Hive.initFlutter();

  // Enregistrement des adaptateurs
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ThemeModeAdapter()); 
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(RecordedSessionTypeAdapter());

  // Overture des box
  await Hive.openBox<Task>('tasksBox');
  await Hive.openBox<Session>('sessionsBox');
  await Hive.openBox('settings');

  await NotificationService().init();
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initializeDateFormatting('fr_FR', null);
  await initDependencies();
  runApp(const ProviderScope(child: TodoWorkSessionsApp()));
}

// On transform en ConsumerWidget pour lire le thème
class TodoWorkSessionsApp extends ConsumerWidget {
  const TodoWorkSessionsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le provider du thème
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Todo Work Sessions',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,  
      themeMode: themeMode, 
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MainWrapper(),
      },
    );
  }
}
