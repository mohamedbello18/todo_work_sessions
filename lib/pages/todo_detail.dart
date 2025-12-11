import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todo_work_sessions/data/models/task.dart';
import 'package:todo_work_sessions/features/application/application_providers.dart';
import 'package:todo_work_sessions/features/tasks/application/task_providers.dart';
import 'package:todo_work_sessions/features/tasks/presentation/task_edit_screen.dart';
import 'package:todo_work_sessions/features/tasks/presentation/widgets/task_list_item.dart';
import 'package:collection/collection.dart';

class TodoDetailPage extends ConsumerStatefulWidget {
  final dynamic taskKey;

  const TodoDetailPage({super.key, required this.taskKey});

  @override
  _TodoDetailPageState createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends ConsumerState<TodoDetailPage> {
  late Task task;

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche et toutes ses sous-tâches ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              ref.read(taskRepositoryProvider).deleteTask(task);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskEditScreen(task: task)),
    ).then((_) => setState(() {})); // Refresh
  }

  void _startSession(Task task) {
    final originalStatus = task.status;
    task.status = TaskStatus.inProgress;
    ref.read(taskRepositoryProvider).updateTask(task, originalStatus: originalStatus);
    ref.read(activeTaskProvider.notifier).state = task;
    ref.read(mainTabIndexProvider.notifier).state = 1;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _addNewSubTask() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TaskEditScreen(task: Task(title: '', createdAt: DateTime.now(), parentTaskKey: task.key)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    task = Hive.box<Task>('tasksBox').get(widget.taskKey)!;
    final allTasks = ref.watch(tasksStreamProvider).value ?? [];
    final subTasks = allTasks.where((t) => t.parentTaskKey == task.key).toList();
    final parentTask = task.parentTaskKey != null ? allTasks.firstWhereOrNull((t) => t.key == task.parentTaskKey) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la tâche"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _navigateToEditScreen),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parentTask != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TodoDetailPage(taskKey: parentTask.key))),
                  child: Row(children: [Text('Parente: ${parentTask.title}', style: const TextStyle(color: Colors.blue))]),
                ),
              ),
            Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(task.description!),
              ),
            const SizedBox(height: 16),
            if (task.scheduledAt != null)
              ListTile(
                leading: const Icon(Icons.alarm, color: Colors.grey),
                title: Text('Prévu pour le ${DateFormat.yMMMd('fr_FR').add_jm().format(task.scheduledAt!)}'),
                contentPadding: EdgeInsets.zero,
              ),
            if (task.dueDate != null)
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.grey),
                title: Text('Échéance le ${DateFormat.yMMMd('fr_FR').format(task.dueDate!)}'),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _startSession(task),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer la session'),
            ),
            const SizedBox(height: 20),
            const Text("Sous-tâches", style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: subTasks.length,
                itemBuilder: (context, index) {
                  final subTask = subTasks[index];
                  return TaskListItem(task: subTask, isSubTask: true);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_detail', // Unique tag
        onPressed: _addNewSubTask,
        child: const Icon(Icons.add),
        tooltip: 'Ajouter une sous-tâche',
      ),
    );
  }
}
