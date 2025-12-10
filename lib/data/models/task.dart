// lib/data/models/task.dart

import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
enum TaskPriority { @HiveField(0) low, @HiveField(1) normal, @HiveField(2) high, @HiveField(3) urgent }

@HiveType(typeId: 2)
enum TaskStatus { @HiveField(0) todo, @HiveField(1) inProgress, @HiveField(2) done, @HiveField(3) postponed }

@HiveType(typeId: 0)
class Task extends HiveObject {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  String title;
  @HiveField(2)
  final String? userId;
  // Le champ 3 (isCompleted) est obsolète et peut être réutilisé si nécessaire dans le futur.
  @HiveField(4)
  final DateTime createdAt;
  @HiveField(5)
  String? description;
  @HiveField(6)
  String? notes;
  @HiveField(7)
  TaskPriority priority;
  @HiveField(8)
  List<String>? tags;
  @HiveField(9)
  DateTime? dueDate;
  @HiveField(10)
  Duration? estimatedDuration;
  @HiveField(11)
  TaskStatus status;
  
  @HiveField(12)
  Duration? reminderOffset;

  @HiveField(13)
  DateTime? startedAt;
  @HiveField(14)
  DateTime? completedAt;
  @HiveField(15)
  DateTime? scheduledAt;

  Task({
    this.id,
    required this.title,
    this.userId,
    required this.createdAt,
    this.description,
    this.notes,
    this.priority = TaskPriority.normal,
    this.tags,
    this.dueDate,
    this.estimatedDuration,
    this.status = TaskStatus.todo,
    this.reminderOffset,
    this.startedAt,
    this.completedAt,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'notes': notes,
      'priority': priority.toString().split('.').last,
      'tags': tags,
      'due_date': dueDate?.toIso8601String(),
      'estimated_duration': estimatedDuration?.inMinutes,
      'status': status.toString().split('.').last,
      'reminder_offset_minutes': reminderOffset?.inMinutes,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
    };
  }
}
