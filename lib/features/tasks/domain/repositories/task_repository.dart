// lib/features/tasks/domain/repositories/task_repository.dart

import '../../../../data/models/task.dart';

/// Le contrat (interface) pour la gestion des données des tâches.
abstract class TaskRepository {
  
  Stream<List<Task>> getTasks();

  Future<void> addTask(Task task);

  // === MÉTHODE MISE À JOUR ===
  /// Met à jour une tâche existante.
  /// 
  /// Le paramètre [originalStatus] est crucial pour permettre au repository
  /// d'appliquer une logique métier basée sur le changement d'état (ex: enregistrer `startedAt`).
  Future<void> updateTask(Task task, {TaskStatus? originalStatus});
  // ==========================

  Future<void> deleteTask(Task task);

}
