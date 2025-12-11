// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 12;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime?,
      taskKey: fields[2] as dynamic,
      sessionType: fields[3] as RecordedSessionType,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.taskKey)
      ..writeByte(3)
      ..write(obj.sessionType)
      ..writeByte(4)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordedSessionTypeAdapter extends TypeAdapter<RecordedSessionType> {
  @override
  final int typeId = 11;

  @override
  RecordedSessionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordedSessionType.task;
      case 1:
        return RecordedSessionType.personal;
      default:
        return RecordedSessionType.task;
    }
  }

  @override
  void write(BinaryWriter writer, RecordedSessionType obj) {
    switch (obj) {
      case RecordedSessionType.task:
        writer.writeByte(0);
        break;
      case RecordedSessionType.personal:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordedSessionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
