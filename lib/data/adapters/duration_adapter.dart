// lib/data/adapters/duration_adapter.dart

import 'package:hive/hive.dart';

/// Un adaptateur pour que Hive puisse stocker et lire le type `Duration`.
/// Hive ne sait pas gérer ce type par défaut, nous devons donc lui apprendre.
class DurationAdapter extends TypeAdapter<Duration> {
  
  // Chaque adaptateur doit avoir un typeId unique.
  // 0: Task, 1: TaskPriority, 2: TaskStatus. On utilise donc 3.
  @override
  final int typeId = 3;

  @override
  Duration read(BinaryReader reader) {
    // On lit le nombre de microsecondes que nous avons précédemment sauvegardé.
    final microseconds = reader.readInt();
    return Duration(microseconds: microseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    // On écrit la durée en tant qu'entier (nombre total de microsecondes).
    // C'est un type primitif que Hive sait gérer.
    writer.writeInt(obj.inMicroseconds);
  }
}
