// lib/features/tasks/presentation/task_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/string_extension.dart';
import '../../../data/models/task.dart';
import '../application/task_providers.dart';
import 'widgets/tag_input_field.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskEditScreen({super.key, this.task});

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController, _descriptionController, _notesController;
  late TaskPriority _priority;
  late TaskStatus _status, _originalStatus;
  DateTime? _dueDate, _scheduledAt;
  Duration? _estimatedDuration, _reminderOffset;
  late List<String> _tags;

  bool get _isEditing => widget.task != null;
  
  final Map<String, Duration> _reminderOptions = {
    'Aucun': Duration.zero,
    '15 minutes avant': const Duration(minutes: 15),
    '1 heure avant': const Duration(hours: 1),
    '1 jour avant': const Duration(days: 1),
  };

  final Map<String, Duration?> _durationOptions = {
    'Non définie': null, '15 minutes': const Duration(minutes: 15), '30 minutes': const Duration(minutes: 30),
    '1 heure': const Duration(hours: 1), '2 heures': const Duration(hours: 2), '4 heures': const Duration(hours: 4),
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _notesController = TextEditingController(text: widget.task?.notes ?? '');
    _priority = widget.task?.priority ?? TaskPriority.normal;
    _status = widget.task?.status ?? TaskStatus.todo;
    _originalStatus = widget.task?.status ?? TaskStatus.todo;
    _dueDate = widget.task?.dueDate;
    _scheduledAt = widget.task?.scheduledAt;
    _estimatedDuration = widget.task?.estimatedDuration;
    _reminderOffset = widget.task?.reminderOffset;
    _tags = widget.task?.tags ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_dueDate != null && _scheduledAt != null && _scheduledAt!.isAfter(_dueDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: La date de démarrage ne peut pas être après la date d\'échéance.'), backgroundColor: Colors.red),
        );
        return;
      }

      final repository = ref.read(taskRepositoryProvider);
      String feedbackMessage;
      if (_isEditing) {
        widget.task!.title = _titleController.text;
        widget.task!.description = _descriptionController.text;
        widget.task!.notes = _notesController.text;
        widget.task!.priority = _priority;
        widget.task!.status = _status;
        widget.task!.dueDate = _dueDate;
        widget.task!.scheduledAt = _scheduledAt;
        widget.task!.reminderOffset = _reminderOffset;
        widget.task!.tags = _tags;
        widget.task!.estimatedDuration = _estimatedDuration;
        repository.updateTask(widget.task!, originalStatus: _originalStatus);
        feedbackMessage = 'Tâche modifiée avec succès !';
      } else {
        final newTask = Task(title: _titleController.text, createdAt: DateTime.now(), description: _descriptionController.text, notes: _notesController.text, priority: _priority, status: _status, dueDate: _dueDate, scheduledAt: _scheduledAt, reminderOffset: _reminderOffset, tags: _tags, estimatedDuration: _estimatedDuration);
        repository.addTask(newTask);
        feedbackMessage = 'Tâche ajoutée avec succès !';
      }
      ref.read(taskFeedbackProvider.notifier).state = feedbackMessage;
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (pickedDate != null) setState(() => _dueDate = pickedDate);
  }

  Future<void> _selectScheduledAt() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(context: context, initialDate: _scheduledAt ?? now, firstDate: now, lastDate: DateTime(2100));
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? now));
    if (pickedTime == null) return;
    setState(() => _scheduledAt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Modifier la Tâche' : 'Nouvelle Tâche'), actions: [IconButton(icon: const Icon(Icons.save_alt_outlined), onPressed: _saveForm, tooltip: 'Sauvegarder')]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titre'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Le titre est obligatoire.' : null),
          const SizedBox(height: 20),
          TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description (optionnel)'), maxLines: 3),
          const SizedBox(height: 20),
          DropdownButtonFormField<TaskPriority>(value: _priority, decoration: const InputDecoration(labelText: 'Priorité'), items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.toString().split('.').last.capitalize()))).toList(), onChanged: (v) => setState(() => _priority = v!)),
          const SizedBox(height: 20),
          DropdownButtonFormField<TaskStatus>(value: _status, decoration: const InputDecoration(labelText: 'Statut'), items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.toString().split('.').last.capitalize()))).toList(), onChanged: (v) => setState(() => _status = v!)),
          const SizedBox(height: 20),
          DropdownButtonFormField<Duration?>(value: _estimatedDuration, decoration: const InputDecoration(labelText: 'Durée Estimée'), items: _durationOptions.entries.map((e) => DropdownMenuItem<Duration?>(value: e.value, child: Text(e.key))).toList(), onChanged: (v) => setState(() => _estimatedDuration = v)),
          const SizedBox(height: 20),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: Text(_dueDate == null ? 'Date d\'échéance' : 'Échéance: ${_dueDate!.toLocal().toString().substring(0, 10)}'), onTap: _selectDueDate, trailing: _dueDate != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() { _dueDate = null; _reminderOffset = null; })) : null),
          if (_dueDate != null) Padding(padding: const EdgeInsets.only(left: 16.0, top: 0, bottom: 10), child: DropdownButtonFormField<Duration>(value: _reminderOffset ?? Duration.zero, decoration: const InputDecoration(labelText: 'Rappel', border: InputBorder.none, prefixIcon: Icon(Icons.notifications_active_outlined)), items: _reminderOptions.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(), onChanged: (v) => setState(() => _reminderOffset = (v == Duration.zero) ? null : v))),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.alarm_add_outlined), title: Text(_scheduledAt == null ? 'Planifier le démarrage' : 'Prévu pour: ${_scheduledAt!.toLocal().toString().substring(0, 16)}'), onTap: _selectScheduledAt, trailing: _scheduledAt != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _scheduledAt = null)) : null),
          const SizedBox(height: 20),
          TagInputField(initialTags: _tags, onChanged: (newTags) => setState(() => _tags = newTags)),
          const SizedBox(height: 20),
          TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes internes (optionnel)'), maxLines: 4),
        ])),
      ),
    );
  }
}
