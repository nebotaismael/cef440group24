// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeofenceAdapter extends TypeAdapter<Geofence> {
  @override
  final int typeId = 8;

  @override
  Geofence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Geofence(
      id: fields[0] as String,
      name: fields[1] as String,
      latitude: fields[2] as double,
      longitude: fields[3] as double,
      radius: fields[4] as double,
      isActive: fields[5] as bool,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Geofence obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude)
      ..writeByte(4)
      ..write(obj.radius)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeofenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
