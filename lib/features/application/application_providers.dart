// lib/features/application/application_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_work_sessions/data/models/task.dart';

/// Provider qui gère l'index de l'onglet de navigation principal.
final mainTabIndexProvider = StateProvider<int>((ref) => 0);

/// Provider qui stocke la tâche actuellement sélectionnée pour une session de travail.
/// 
/// Il est `null` si aucune tâche n'est en cours de session.
final activeTaskProvider = StateProvider<Task?>((ref) => null);
