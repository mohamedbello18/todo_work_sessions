import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todo_work_sessions/data/models/attachment.dart';
import 'package:todo_work_sessions/data/models/comment.dart';
import 'package:todo_work_sessions/data/models/history_event.dart';
import 'package:todo_work_sessions/data/models/task.dart';
import 'package:todo_work_sessions/features/application/application_providers.dart';
import 'package:todo_work_sessions/features/tasks/application/task_providers.dart';
import 'package:todo_work_sessions/features/tasks/presentation/task_edit_screen.dart';
import 'package:todo_work_sessions/features/tasks/presentation/widgets/task_list_item.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class TodoDetailPage extends ConsumerStatefulWidget {
  final dynamic taskKey;

  const TodoDetailPage({super.key, required this.taskKey});

  @override
  _TodoDetailPageState createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends ConsumerState<TodoDetailPage> {
  late Task task;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche, ses sous-tâches et tout son historique ?'),
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
    ).then((_) => setState(() {}));
  }

  void _startSession(Task task) {
    ref.read(taskRepositoryProvider).updateTask(task, originalStatus: task.status);
    ref.read(activeTaskProvider.notifier).state = task;
    ref.read(mainTabIndexProvider.notifier).state = 1;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _addNewSubTask() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TaskEditScreen(task: Task(title: '', createdAt: DateTime.now(), parentTaskKey: task.key)),
    ));
  }

  void _addLinkDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un lien'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom du lien')),
          TextField(controller: urlController, decoration: const InputDecoration(labelText: 'URL')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final attachment = Attachment(name: nameController.text, path: urlController.text, type: AttachmentType.link);
                final box = Hive.box<Attachment>('attachmentsBox');
                await box.add(attachment);
                task.attachments ??= HiveList(box);
                task.attachments!.add(attachment);
                await task.save();
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = p.basename(file.path);
    final appDir = await getApplicationDocumentsDirectory();
    final newPath = '${appDir.path}/$fileName';
    await file.copy(newPath);

    final attachment = Attachment(name: fileName, path: newPath, type: AttachmentType.file);
    final box = Hive.box<Attachment>('attachmentsBox');
    await box.add(attachment);

    task.attachments ??= HiveList(box);
    task.attachments!.add(attachment);
    await task.save();
    setState(() {});
  }

  IconData _getIconForAttachment(Attachment attachment) {
    if (attachment.type == AttachmentType.link) return Icons.link;
    final extension = p.extension(attachment.path).toLowerCase();
    switch (extension) {
      case '.pdf': return Icons.picture_as_pdf;
      case '.doc': case '.docx': return Icons.description;
      case '.jpg': case '.jpeg': case '.png': return Icons.image;
      default: return Icons.attach_file;
    }
  }

  void _handleAttachmentTap(Attachment attachment) {
    if (attachment.type == AttachmentType.link) {
      launchUrl(Uri.parse(attachment.path), mode: LaunchMode.externalApplication);
    } else {
      OpenFile.open(attachment.path);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;
    final comment = Comment(text: _commentController.text, createdAt: DateTime.now());
    final box = Hive.box<Comment>('commentsBox');
    await box.add(comment);

    task.comments ??= HiveList(box);
    task.comments!.add(comment);
    await task.save();

    _commentController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    task = Hive.box<Task>('tasksBox').get(widget.taskKey)!;
    final allTasks = ref.watch(tasksStreamProvider).value ?? [];
    final subTasks = allTasks.where((t) => t.parentTaskKey == task.key).toList();
    final isSubTask = task.parentTaskKey != null;

    final combinedActivity = <dynamic>[...?task.comments, ...?task.history];
    combinedActivity.sort((a, b) {
      final dateA = a is Comment ? a.createdAt : (a as HistoryEvent).timestamp;
      final dateB = b is Comment ? b.createdAt : (b as HistoryEvent).timestamp;
      return dateB.compareTo(dateA); // Sort descending
    });

    return Scaffold(
      appBar: AppBar(title: Text(task.title), actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: _navigateToEditScreen),
        IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
      ]),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
                if (task.description != null && task.description!.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(task.description!)),
                const SizedBox(height: 16),
                if (task.scheduledAt != null) ListTile(leading: const Icon(Icons.alarm, color: Colors.grey), title: Text('Prévu pour le ${DateFormat.yMMMd('fr_FR').add_jm().format(task.scheduledAt!)}'), contentPadding: EdgeInsets.zero),
                if (task.dueDate != null) ListTile(leading: const Icon(Icons.calendar_today, color: Colors.grey), title: Text('Échéance le ${DateFormat.yMMMd('fr_FR').format(task.dueDate!)}'), contentPadding: EdgeInsets.zero),
                const SizedBox(height: 20),
                ElevatedButton.icon(onPressed: () => _startSession(task), icon: const Icon(Icons.play_arrow), label: const Text('Démarrer la session')),
                
                const SizedBox(height: 20),
                const Text("Pièces Jointes", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                if (task.attachments?.isNotEmpty ?? false)
                  ...task.attachments!.map((attachment) => ListTile(leading: Icon(_getIconForAttachment(attachment)), title: Text(attachment.name), onTap: () => _handleAttachmentTap(attachment), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await attachment.delete(); setState(() {}); }))),
                PopupMenuButton<String>(
                  onSelected: (value) { if (value == 'link') _addLinkDialog(); if (value == 'file') _pickFile(); },
                  itemBuilder: (context) => [const PopupMenuItem(value: 'link', child: Text('Ajouter un lien')), const PopupMenuItem(value: 'file', child: Text('Ajouter un fichier'))],
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add), SizedBox(width: 8), Text('Ajouter une pièce jointe')]),
                ),

                if (!isSubTask) ...[
                  const SizedBox(height: 20),
                  const Text("Sous-tâches", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...subTasks.map((subTask) => GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TodoDetailPage(taskKey: subTask.key))), child: TaskListItem(task: subTask, isSubTask: true))),
                ],

                const SizedBox(height: 20),
                const Text("Activité", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                ...combinedActivity.map((event) {
                  if (event is Comment) { return ListTile(leading: const Icon(Icons.comment_outlined), title: Text(event.text), subtitle: Text(DateFormat.yMMMd('fr_FR').add_jm().format(event.createdAt))); }
                  if (event is HistoryEvent) { return ListTile(leading: const Icon(Icons.history_outlined), title: Text(event.changeDescription), subtitle: Text(DateFormat.yMMMd('fr_FR').add_jm().format(event.timestamp))); }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: 'Ajouter un commentaire...'))), IconButton(icon: const Icon(Icons.send), onPressed: _addComment)]),
          ),
        ],
      ),
      floatingActionButton: !isSubTask
          ? FloatingActionButton(heroTag: 'fab_detail', onPressed: _addNewSubTask, child: const Icon(Icons.add), tooltip: 'Ajouter une sous-tâche')
          : null,
    );
  }
}
