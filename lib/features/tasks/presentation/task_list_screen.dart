import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_work_sessions/features/tasks/domain/task_filter.dart';
import 'package:todo_work_sessions/features/tasks/domain/task_view_mode.dart';
import 'package:todo_work_sessions/features/tasks/presentation/widgets/kanban_view.dart';
import 'package:todo_work_sessions/pages/todo_detail.dart';
import '../../../data/models/task.dart';
import '../application/task_providers.dart';
import 'widgets/task_list_item.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final _tagSearchController = TextEditingController();

  @override
  void dispose() {
    _tagSearchController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDateTime(BuildContext context, DateTime? initialDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (pickedTime == null) return pickedDate;

    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
  }

  void _showFilterPanel() {
    final allTags = ref.read(allTagsProvider);
    final primaryColor = Theme.of(context).primaryColor;
    _tagSearchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final filter = ref.watch(taskFilterProvider);

          return StatefulBuilder(builder: (context, setSheetState) {
            final searchInput = _tagSearchController.text.toLowerCase();
            final suggestedTags = searchInput.isEmpty
                ? <String>[]
                : allTags.where((tag) => tag.toLowerCase().contains(searchInput) && !filter.tags.contains(tag)).toList();

            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filtres', style: Theme.of(context).textTheme.headlineSmall),
                      const Divider(),

                      // Status Filter
                      Text('Statut', style: Theme.of(context).textTheme.titleLarge),
                      Wrap(
                        spacing: 8.0,
                        children: TaskStatus.values.map((status) {
                          final isSelected = filter.statuses.contains(status);
                          return FilterChip(
                            label: Text(status.toString().split('.').last),
                            selected: isSelected,
                            onSelected: (selected) {
                              final newStatuses = Set<TaskStatus>.from(filter.statuses);
                              if (selected) { newStatuses.add(status); } else { newStatuses.remove(status); }
                              ref.read(taskFilterProvider.notifier).state = filter.copyWith(statuses: newStatuses);
                            },
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                          );
                        }).toList(),
                      ),

                      // Priority Filter
                      const SizedBox(height: 16),
                      Text('Priorité', style: Theme.of(context).textTheme.titleLarge),
                      Wrap(
                        spacing: 8.0,
                        children: TaskPriority.values.map((priority) {
                          final isSelected = filter.priorities.contains(priority);
                          return FilterChip(
                            label: Text(priority.toString().split('.').last),
                            selected: isSelected,
                            onSelected: (selected) {
                              final newPriorities = Set<TaskPriority>.from(filter.priorities);
                              if (selected) { newPriorities.add(priority); } else { newPriorities.remove(priority); }
                              ref.read(taskFilterProvider.notifier).state = filter.copyWith(priorities: newPriorities);
                            },
                            selectedColor: primaryColor,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                          );
                        }).toList(),
                      ),

                      // Tag Filter
                      const SizedBox(height: 16),
                      Text('Tags', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8.0),
                      if (filter.tags.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children: filter.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              onDeleted: () {
                                final newTags = Set<String>.from(filter.tags)..remove(tag);
                                ref.read(taskFilterProvider.notifier).state = filter.copyWith(tags: newTags);
                              },
                            );
                          }).toList(),
                        ),
                      TextField(
                        controller: _tagSearchController,
                        decoration: const InputDecoration(hintText: 'Rechercher et ajouter un tag...'),
                        onChanged: (value) => setSheetState(() {}),
                      ),
                      if (suggestedTags.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          children: suggestedTags.map((tag) {
                            return ActionChip(
                              label: Text(tag),
                              onPressed: () {
                                final newTags = Set<String>.from(filter.tags)..add(tag);
                                ref.read(taskFilterProvider.notifier).state = filter.copyWith(tags: newTags);
                                _tagSearchController.clear();
                                setSheetState(() {});
                              },
                            );
                          }).toList(),
                        ),

                      // Date Filter
                      const SizedBox(height: 16),
                      Text('Date', style: Theme.of(context).textTheme.titleLarge),
                      Row(
                        children: [
                          Expanded(child: ElevatedButton(onPressed: () async { final picked = await _selectDateTime(context, filter.startDate); ref.read(taskFilterProvider.notifier).state = filter.copyWith(startDate: picked); }, child: Text(filter.startDate == null ? 'Début' : DateFormat.yMd('fr_FR').add_Hm().format(filter.startDate!)))),
                          if (filter.startDate != null) IconButton(icon: const Icon(Icons.clear), onPressed: () => ref.read(taskFilterProvider.notifier).state = filter.copyWith(clearStartDate: true)),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: () async { final picked = await _selectDateTime(context, filter.endDate); ref.read(taskFilterProvider.notifier).state = filter.copyWith(endDate: picked); }, child: Text(filter.endDate == null ? 'Fin' : DateFormat.yMd('fr_FR').add_Hm().format(filter.endDate!)))),
                          if (filter.endDate != null) IconButton(icon: const Icon(Icons.clear), onPressed: () => ref.read(taskFilterProvider.notifier).state = filter.copyWith(clearEndDate: true)),
                        ],
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.read(taskFilterProvider.notifier).state = const TaskFilter(),
                        child: const Text('Réinitialiser tous les filtres'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(taskFeedbackProvider, (previous, next) {
      if (next != null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next), duration: const Duration(seconds: 2))); ref.read(taskFeedbackProvider.notifier).state = null; }
    });

    final filteredTasks = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final viewMode = ref.watch(taskViewModeProvider);

    final parentTasks = filteredTasks.where((task) => task.parentTaskKey == null).toList();
    parentTasks.sort((a, b) { if (a.status == TaskStatus.done && b.status != TaskStatus.done) return 1; if (a.status != TaskStatus.done && b.status == TaskStatus.done) return -1; return b.createdAt.compareTo(a.createdAt); });

    final Map<TaskViewMode, IconData> viewIcons = {
      TaskViewMode.list: Icons.view_list_outlined,
      TaskViewMode.kanban: Icons.view_kanban_outlined,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches de Travail'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterPanel),
          PopupMenuButton<TaskViewMode>(
            icon: Icon(viewIcons[viewMode]!),
            onSelected: (TaskViewMode newMode) => ref.read(taskViewModeProvider.notifier).state = newMode,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<TaskViewMode>>[
              const PopupMenuItem<TaskViewMode>(value: TaskViewMode.list, child: Text('Liste')),
              const PopupMenuItem<TaskViewMode>(value: TaskViewMode.kanban, child: Text('Kanban')),
            ],
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (filteredTasks.isEmpty && !filter.isFilterActive) { return const Center(child: Text('Aucune tâche pour le moment.\nAppuyez sur + pour en ajouter une !', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey))); }
        if (filteredTasks.isEmpty) { return const Center(child: Text('Aucune tâche ne correspond à vos filtres.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey))); }

        switch (viewMode) {
          case TaskViewMode.kanban:
            return const KanbanView();
          case TaskViewMode.list:
          default:
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: parentTasks.length,
              itemBuilder: (context, index) {
                final task = parentTasks[index];
                return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TodoDetailPage(taskKey: task.key))), child: TaskListItem(task: task));
              },
            );
        }
      }),
    );
  }
}
