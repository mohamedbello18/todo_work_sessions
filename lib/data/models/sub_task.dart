import 'package:hive/hive.dart';

part 'sub_task.g.dart';

@HiveType(typeId: 10) // Using a new typeId
class SubTask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  SubTask({required this.title, this.isCompleted = false});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
