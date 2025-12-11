import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 11)
enum RecordedSessionType {
  @HiveField(0)
  task,
  
  @HiveField(1)
  personal,
}

@HiveType(typeId: 12)
class Session extends HiveObject {
  @HiveField(0)
  DateTime startTime;

  @HiveField(1)
  DateTime? endTime;

  @HiveField(2)
  final dynamic taskKey;

  @HiveField(3)
  final RecordedSessionType sessionType;

  @HiveField(4)
  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    // If the session is still active, show running duration
    return DateTime.now().difference(startTime);
  }

  Session({
    required this.startTime,
    this.endTime,
    this.taskKey,
    required this.sessionType,
  });
}
