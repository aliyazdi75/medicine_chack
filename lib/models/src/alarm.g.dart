// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 2;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as int,
      alarmIds: (fields[1] as List).cast<int>(),
      name: fields[2] as String,
      startAt: fields[3] as DateTime,
      selectedDays: (fields[4] as List).cast<bool>(),
      periodHourIndex: fields[5] as int?,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alarmIds)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.startAt)
      ..writeByte(4)
      ..write(obj.selectedDays)
      ..writeByte(5)
      ..write(obj.periodHourIndex)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
