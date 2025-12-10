// lib/features/tasks/application/task_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/application/service_providers.dart';
import '../../../data/models/task.dart';
import '../data/repositories/hive_task_repository_impl.dart';
import '../domain/repositories/task_repository.dart';

// ... (providers 1, 2, 3, 4 inchangés) ...
final _taskBoxProvider = Provider<Box<Task>>((ref) => Hive.box<Task>('tasksBox'));
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = ref.watch(_taskBoxProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return HiveTaskRepositoryImpl(box, notificationService);
});
final tasksStreamProvider = StreamProvider<List<Task>>((ref) => ref.watch(taskRepositoryProvider).getTasks());
final taskFeedbackProvider = StateProvider<String?>((ref) => null);

// === NOUVEAU PROVIDER POUR LES ÉTIQUETTES ===

/// Fournit une liste unique et triée de toutes les étiquettes (tags) utilisées dans l'application.
/// 
/// Il écoute le [tasksStreamProvider] et, à chaque nouvelle liste de tâches,
/// il parcourt toutes les tâches, collecte toutes les étiquettes, supprime les doublons,
/// et retourne une liste alphabétique.
final allTagsProvider = Provider<List<String>>((ref) {
  // On écoute le provider du flux de tâches pour réagir aux changements.
  final tasksAsyncValue = ref.watch(tasksStreamProvider);

  // On retourne une liste vide pendant le chargement ou en cas d'erreur.
  return tasksAsyncValue.when(
    data: (tasks) {
      // On utilise un Set pour garantir l'unicité des étiquettes.
      final tagSet = <String>{};
      for (final task in tasks) {
        if (task.tags != null) {
          tagSet.addAll(task.tags!);
        }
      }
      // On convertit le Set en une List et on la trie par ordre alphabétique.
      final tagList = tagSet.toList();
      tagList.sort();
      return tagList;
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});
