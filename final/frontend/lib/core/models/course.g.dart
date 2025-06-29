// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final int typeId = 1;

  @override
  Course read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      id: fields[0] as String,
      name: fields[1] as String,
      code: fields[2] as String,
      description: fields[3] as String,
      instructorId: fields[4] as String,
      creditHours: fields[5] as int,
      semester: fields[6] as String,
      academicYear: fields[7] as String,
      status: fields[8] as CourseStatus,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.code)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.instructorId)
      ..writeByte(5)
      ..write(obj.creditHours)
      ..writeByte(6)
      ..write(obj.semester)
      ..writeByte(7)
      ..write(obj.academicYear)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CourseStatusAdapter extends TypeAdapter<CourseStatus> {
  @override
  final int typeId = 2;

  @override
  CourseStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CourseStatus.active;
      case 1:
        return CourseStatus.inactive;
      case 2:
        return CourseStatus.archived;
      case 3:
        return CourseStatus.draft;
      default:
        return CourseStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, CourseStatus obj) {
    switch (obj) {
      case CourseStatus.active:
        writer.writeByte(0);
        break;
      case CourseStatus.inactive:
        writer.writeByte(1);
        break;
      case CourseStatus.archived:
        writer.writeByte(2);
        break;
      case CourseStatus.draft:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
