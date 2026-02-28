// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_intake.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyIntakeAdapter extends TypeAdapter<DailyIntake> {
  @override
  final int typeId = 4;

  @override
  DailyIntake read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyIntake(
      date: fields[0] as DateTime,
      amount: fields[1] as int,
      goal: fields[2] as int,
      entries: (fields[3] as List?)?.cast<DrinkEntry>(),
      temperature: fields[4] as double?,
      weatherCondition: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyIntake obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.goal)
      ..writeByte(3)
      ..write(obj.entries)
      ..writeByte(4)
      ..write(obj.temperature)
      ..writeByte(5)
      ..write(obj.weatherCondition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyIntakeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DrinkEntryAdapter extends TypeAdapter<DrinkEntry> {
  @override
  final int typeId = 5;

  @override
  DrinkEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrinkEntry(
      timestamp: fields[0] as DateTime,
      amount: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DrinkEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrinkEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
