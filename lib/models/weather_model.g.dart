// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override
  final int typeId = 2;

  @override
  WeatherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherModel(
      temperatureC: fields[0] as double,
      feelsLikeC: fields[1] as double,
      conditionText: fields[2] as String,
      conditionCode: fields[3] as int,
      humidity: fields[4] as int,
      windKph: fields[5] as double,
      lastUpdated: fields[6] as DateTime,
      cityName: fields[7] as String,
      country: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.temperatureC)
      ..writeByte(1)
      ..write(obj.feelsLikeC)
      ..writeByte(2)
      ..write(obj.conditionText)
      ..writeByte(3)
      ..write(obj.conditionCode)
      ..writeByte(4)
      ..write(obj.humidity)
      ..writeByte(5)
      ..write(obj.windKph)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.cityName)
      ..writeByte(8)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HeatLevelAdapter extends TypeAdapter<HeatLevel> {
  @override
  final int typeId = 3;

  @override
  HeatLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HeatLevel.comfortable;
      case 1:
        return HeatLevel.moderate;
      case 2:
        return HeatLevel.high;
      case 3:
        return HeatLevel.veryHigh;
      case 4:
        return HeatLevel.extreme;
      default:
        return HeatLevel.comfortable;
    }
  }

  @override
  void write(BinaryWriter writer, HeatLevel obj) {
    switch (obj) {
      case HeatLevel.comfortable:
        writer.writeByte(0);
        break;
      case HeatLevel.moderate:
        writer.writeByte(1);
        break;
      case HeatLevel.high:
        writer.writeByte(2);
        break;
      case HeatLevel.veryHigh:
        writer.writeByte(3);
        break;
      case HeatLevel.extreme:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeatLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
