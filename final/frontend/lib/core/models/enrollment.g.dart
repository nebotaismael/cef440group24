// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnrollmentAdapter extends TypeAdapter<Enrollment> {
  @override
  final int typeId = 7;

  @override
  Enrollment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Enrollment(
      id: fields[0] as String,
      studentId: fields[1] as String,
      courseId: fields[2] as String,
      enrolledAt: fields[3] as DateTime,
      status: fields[4] as EnrollmentStatus,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Enrollment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.courseId)
      ..writeByte(3)
      ..write(obj.enrolledAt)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrollmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EnrollmentStatusAdapter extends TypeAdapter<EnrollmentStatus> {
  @override
  final int typeId = 8;

  @override
  EnrollmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnrollmentStatus.active;
      case 1:
        return EnrollmentStatus.inactive;
      case 2:
        return EnrollmentStatus.dropped;
      case 3:
        return EnrollmentStatus.completed;
      default:
        return EnrollmentStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, EnrollmentStatus obj) {
    switch (obj) {
      case EnrollmentStatus.active:
        writer.writeByte(0);
        break;
      case EnrollmentStatus.inactive:
        writer.writeByte(1);
        break;
      case EnrollmentStatus.dropped:
        writer.writeByte(2);
        break;
      case EnrollmentStatus.completed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnrollmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
