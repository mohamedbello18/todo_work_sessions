// lib/features/tasks/data/repositories/hive_task_repository_impl.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../data/models/task.dart';
import '../../domain/repositories/task_repository.dart';

class HiveTaskRepositoryImpl implements TaskRepository {
  
  final Box<Task> _tasksBox;
  final NotificationService _notificationService;

  HiveTaskRepositoryImpl(this._tasksBox, this._notificationService);

  @override
  Future<void> addTask(Task task) async {
    // === CORRECTION : APPEL SIMPLIFIÉ ===
    // La méthode `add` ajoute la tâche, la sauvegarde, et met à jour sa clé.
    // L'appel `save()` redondant a été supprimé car il pouvait causer des problèmes.
    await _tasksBox.add(task);
    _scheduleNotifications(task); // On planifie les notifications après que la tâche a une clé.
  }

  @override
  Future<void> deleteTask(Task task) async {
    final int notificationId = task.key as int;
    final int scheduledId = notificationId + 1000000;
    _notificationService.cancelNotification(notificationId);
    _notificationService.cancelNotification(scheduledId);
    await task.delete();
  }

  @override
  Stream<List<Task>> getTasks() async* {
    yield _tasksBox.values.toList();
    yield* _tasksBox.watch().map((event) => _tasksBox.values.toList());
  }

  @override
  Future<void> updateTask(Task task, {TaskStatus? originalStatus}) async {
    if (originalStatus != null && task.status != originalStatus) {
      if (task.status == TaskStatus.inProgress && task.startedAt == null) task.startedAt = DateTime.now();
      if (task.status == TaskStatus.done) task.completedAt = DateTime.now();
      else if (originalStatus == TaskStatus.done) task.completedAt = null;
    }

    await task.save();
    _scheduleNotifications(task);
  }

  void _scheduleNotifications(Task task) {
    final int notificationId = task.key as int;
    final int scheduledId = notificationId + 1000000;

    _notificationService.cancelNotification(notificationId);
    _notificationService.cancelNotification(scheduledId);

    if (task.status == TaskStatus.done || task.status == TaskStatus.postponed) return;

    if (task.dueDate != null && task.reminderOffset != null) {
      final reminderDate = task.dueDate!.subtract(task.reminderOffset!);
      if (reminderDate.isAfter(DateTime.now())) {
        _notificationService.scheduleNotification(
          id: notificationId,
          title: "Rappel: ${task.title}",
          body: "Cette tâche est due pour ${task.dueDate!.toLocal().toString().substring(0, 10)}.",
          scheduledDate: reminderDate,
        );
      }
    }

    if (task.scheduledAt != null && task.scheduledAt!.isAfter(DateTime.now())) {
      _notificationService.scheduleNotification(
        id: scheduledId,
        title: "Tâche planifiée: ${task.title}",
        body: "Il est l'heure de commencer cette tâche !",
        scheduledDate: task.scheduledAt!,
      );
    }
  }
}
