import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../data/models/attachment.dart';
import '../../../../data/models/comment.dart';
import '../../../../data/models/history_event.dart';
import '../../../../data/models/task.dart';
import '../../domain/repositories/task_repository.dart';

class HiveTaskRepositoryImpl implements TaskRepository {
  
  final Box<Task> _tasksBox;
  final Box<Comment> _commentsBox;
  final Box<HistoryEvent> _historyEventsBox;
  final Box<Attachment> _attachmentsBox;
  final NotificationService _notificationService;

  HiveTaskRepositoryImpl(this._tasksBox, this._commentsBox, this._historyEventsBox, this._attachmentsBox, this._notificationService);

  @override
  Future<void> addTask(Task task) async {
    final historyEvent = HistoryEvent(changeDescription: 'Tâche créée', timestamp: DateTime.now());
    await _historyEventsBox.add(historyEvent);
    task.history = HiveList(_historyEventsBox)..add(historyEvent);
    
    await _tasksBox.add(task);
    _scheduleNotifications(task);
  }

  @override
  Future<void> deleteTask(Task task) async {
    final allTasks = _tasksBox.values.toList();
    final subTasks = allTasks.where((t) => t.parentTaskKey == task.key).toList();

    for (final subTask in subTasks) {
      await _deleteSingleTask(subTask);
    }

    await _deleteSingleTask(task);
  }

  Future<void> _deleteSingleTask(Task task) async {
    final int notificationId = task.key as int;
    _notificationService.cancelNotification(notificationId);
    _notificationService.cancelNotification(notificationId + 1000000);

    // Use a copy of the list to avoid concurrent modification errors
    final commentsToDelete = List.from(task.comments ?? []);
    for (var comment in commentsToDelete) {
      await comment.delete();
    }

    final historyToDelete = List.from(task.history ?? []);
    for (var event in historyToDelete) {
      await event.delete();
    }

    final attachmentsToDelete = List.from(task.attachments ?? []);
    for (var attachment in attachmentsToDelete) {
      await attachment.delete();
    }

    await task.delete();
  }

  @override
  Stream<List<Task>> getTasks() async* {
    yield _tasksBox.values.toList();
    yield* _tasksBox.watch().map((event) => _tasksBox.values.toList());
  }

  @override
  Future<void> updateTask(Task task, {TaskStatus? originalStatus}) async {
    final now = DateTime.now();
    task.history ??= HiveList(_historyEventsBox);

    if (originalStatus != null && task.status != originalStatus) {
      final event = HistoryEvent(changeDescription: 'Statut changé de ${originalStatus.toString().split('.').last} à ${task.status.toString().split('.').last}', timestamp: now);
      await _historyEventsBox.add(event);
      task.history!.add(event);

      if (task.status == TaskStatus.inProgress && task.startedAt == null) task.startedAt = now;
      if (task.status == TaskStatus.done) {
        task.completedAt = now;
      } else if (originalStatus == TaskStatus.done) task.completedAt = null;
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
