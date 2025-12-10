// lib/features/tasks/presentation/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task.dart';
import '../application/task_providers.dart';
import 'widgets/task_list_item.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // === ÉCOUTEUR POUR LES SNACKBARS ===
    ref.listen<String?>(taskFeedbackProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            duration: const Duration(seconds: 2),
          ),
        );
        // On réinitialise le provider pour ne pas réafficher le message
        ref.read(taskFeedbackProvider.notifier).state = null;
      }
    });
    // ===================================

    final tasksAsyncValue = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Tâches de Travail')),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'Aucune tâche pour le moment.\nAppuyez sur + pour en ajouter une !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final sortedTasks = List<Task>.from(tasks);
          sortedTasks.sort((a, b) {
            if (a.status == TaskStatus.done && b.status != TaskStatus.done) return 1;
            if (a.status != TaskStatus.done && b.status == TaskStatus.done) return -1;
            return b.createdAt.compareTo(a.createdAt);
          });

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return TaskListItem(task: task);
            },
          );
        },
        error: (err, stack) => Center(
          child: Text("Erreur: $err", style: const TextStyle(color: Colors.red)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
