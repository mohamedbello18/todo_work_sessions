// lib/features/tasks/presentation/widgets/task_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_work_sessions/features/tasks/presentation/task_edit_screen.dart';
import '../../../../core/utils/string_extension.dart';
import '../../../../data/models/task.dart';
import '../../../application/application_providers.dart';
import '../../application/task_providers.dart';

class TaskListItem extends ConsumerWidget {
  final Task task;
  final bool isSubTask;

  const TaskListItem({super.key, required this.task, this.isSubTask = false});

  Color _getPriorityColor(BuildContext context, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent: return Colors.red.shade700;
      case TaskPriority.high: return Colors.amber.shade700;
      case TaskPriority.low: return Colors.blue.shade600;
      default: return Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.5);
    }
  }

  String _getStatusText(TaskStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ' ${m.group(0)}',
    ).capitalize();
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette tâche ?'),
          actions: <Widget>[
            TextButton(child: const Text('Annuler'), onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text('Supprimer'),
              onPressed: () {
                ref.read(taskRepositoryProvider).deleteTask(task);
                ref.read(taskFeedbackProvider.notifier).state = 'Tâche supprimée';
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  (String, Color) _getDueDateIndicator(BuildContext context) {
    if (task.dueDate == null) return ('', Colors.transparent);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    final difference = dueDate.difference(today).inDays;
    if (difference < 0) return ('En retard de ${difference.abs()} j', Colors.red.shade700);
    if (difference == 0) return ('Dû aujourd\'hui', Colors.amber.shade800);
    if (difference == 1) return ('Dû demain', Colors.amber.shade700);
    if (difference <= 7) return ('Dû dans $difference j', Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.9));
    return ('', Colors.transparent);
  }

  void _startSession(BuildContext context, WidgetRef ref) {
    final originalStatus = task.status;
    task.status = TaskStatus.inProgress;
    ref.read(taskRepositoryProvider).updateTask(task, originalStatus: originalStatus);
    ref.read(activeTaskProvider.notifier).state = task;
    ref.read(mainTabIndexProvider.notifier).state = 1;
    // If we are on a detail page, pop until we are back on the main screen
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorityColor = _getPriorityColor(context, task.priority);
    final (dueDateText, dueDateColor) = _getDueDateIndicator(context);
    final bool isStartable = task.status == TaskStatus.todo || task.status == TaskStatus.postponed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: isSubTask ? const Icon(Icons.subdirectory_arrow_right, size: 20) : Container(width: 5, decoration: BoxDecoration(color: priorityColor, borderRadius: BorderRadius.circular(4))),
        title: Text(task.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null, color: task.status == TaskStatus.done ? Colors.grey : null)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(children: [
            Text(_getStatusText(task.status), style: TextStyle(color: task.status == TaskStatus.done ? Colors.grey : null)),
            if (dueDateText.isNotEmpty && task.status != TaskStatus.done && task.status != TaskStatus.postponed) ...[
              const Text(' • ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(dueDateText, style: TextStyle(color: dueDateColor, fontWeight: FontWeight.w500)),
            ],
          ]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStartable)
              IconButton(
                icon: const Icon(Icons.play_circle_outline, color: Color(0xFF2ECC71)),
                tooltip: 'Démarrer la session',
                onPressed: () => _startSession(context, ref),
              ),
            Checkbox(value: task.status == TaskStatus.done, onChanged: (v) {
              if (v != null) {
                final originalStatus = task.status;
                task.status = v ? TaskStatus.done : TaskStatus.todo;
                ref.read(taskRepositoryProvider).updateTask(task, originalStatus: originalStatus);
              }
            }),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskEditScreen(task: task)));
                } else if (value == 'delete') {
                  _showDeleteConfirmationDialog(context, ref);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Text('Modifier')),
                const PopupMenuItem<String>(value: 'delete', child: Text('Supprimer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
