// lib/features/tasks/application/task_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/application/service_providers.dart';
import '../../../data/models/attachment.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/history_event.dart';
import '../../../data/models/task.dart';
import '../data/repositories/hive_task_repository_impl.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/task_filter.dart';
import '../domain/task_view_mode.dart';

// Provider for the view mode
final taskViewModeProvider = StateProvider<TaskViewMode>((ref) => TaskViewMode.list);

// Provider for the filter state
final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

// Hive Box Providers
final _taskBoxProvider = Provider<Box<Task>>((ref) => Hive.box<Task>('tasksBox'));
final _commentBoxProvider = Provider<Box<Comment>>((ref) => Hive.box<Comment>('commentsBox'));
final _historyBoxProvider = Provider<Box<HistoryEvent>>((ref) => Hive.box<HistoryEvent>('historyEventsBox'));
final _attachmentBoxProvider = Provider<Box<Attachment>>((ref) => Hive.box<Attachment>('attachmentsBox'));

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final taskBox = ref.watch(_taskBoxProvider);
  final commentBox = ref.watch(_commentBoxProvider);
  final historyBox = ref.watch(_historyBoxProvider);
  final attachmentBox = ref.watch(_attachmentBoxProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return HiveTaskRepositoryImpl(taskBox, commentBox, historyBox, attachmentBox, notificationService);
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) => ref.watch(taskRepositoryProvider).getTasks());

// Provider that applies the filters
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksStreamProvider).value ?? [];
  final filter = ref.watch(taskFilterProvider);

  return tasks.where((task) {
    final statusMatch = filter.statuses.isEmpty || filter.statuses.contains(task.status);
    final priorityMatch = filter.priorities.isEmpty || filter.priorities.contains(task.priority);
    final tagMatch = filter.tags.isEmpty || (task.tags?.any((t) => filter.tags.contains(t)) ?? false);
    final startDateMatch = filter.startDate == null || (task.dueDate?.isAfter(filter.startDate!.subtract(const Duration(days: 1))) ?? false);
    final endDateMatch = filter.endDate == null || (task.dueDate?.isBefore(filter.endDate!.add(const Duration(days: 1))) ?? false);

    return statusMatch && priorityMatch && tagMatch && startDateMatch && endDateMatch;
  }).toList();
});

final taskFeedbackProvider = StateProvider<String?>((ref) => null);

final allTagsProvider = Provider<List<String>>((ref) {
  final tasksAsyncValue = ref.watch(tasksStreamProvider);
  return tasksAsyncValue.when(
    data: (tasks) {
      final tagSet = <String>{};
      for (final task in tasks) {
        if (task.tags != null) {
          tagSet.addAll(task.tags!);
        }
      }
      final tagList = tagSet.toList();
      tagList.sort();
      return tagList;
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});
