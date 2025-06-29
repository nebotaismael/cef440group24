import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'course.g.dart';

@HiveType(typeId: 1)
class Course extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String code;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String instructorId;

  @HiveField(5)
  final int creditHours;

  @HiveField(6)
  final String semester;

  @HiveField(7)
  final String academicYear;

  @HiveField(8)
  final CourseStatus status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.instructorId,
    required this.creditHours,
    required this.semester,
    required this.academicYear,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Course from a Firestore document
  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Course(
      id: document.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      creditHours: data['creditHours'] ?? 0,
      semester: data['semester'] ?? '',
      academicYear: data['academicYear'] ?? '',
      status: CourseStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => CourseStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert Course to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'instructorId': instructorId,
      'creditHours': creditHours,
      'semester': semester,
      'academicYear': academicYear,
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? instructorId,
    int? creditHours,
    String? semester,
    String? academicYear,
    CourseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      creditHours: creditHours ?? this.creditHours,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'instructorId': instructorId,
      'creditHours': creditHours,
      'semester': semester,
      'academicYear': academicYear,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      instructorId: json['instructorId'],
      creditHours: json['creditHours'],
      semester: json['semester'],
      academicYear: json['academicYear'],
      status: CourseStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 2)
enum CourseStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  archived,
  @HiveField(3)
  draft,
}
