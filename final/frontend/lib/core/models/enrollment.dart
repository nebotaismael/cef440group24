import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'enrollment.g.dart';

@HiveType(typeId: 7)
class Enrollment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String courseId;

  @HiveField(3)
  final DateTime enrolledAt;

  @HiveField(4)
  final EnrollmentStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrolledAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create an Enrollment from a Firestore document
  factory Enrollment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Enrollment(
      id: document.id,
      studentId: data['studentId'] ?? '',
      courseId: data['courseId'] ?? '',
      enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
      status: EnrollmentStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => EnrollmentStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Enrollment to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Enrollment copyWith({
    String? id,
    String? studentId,
    String? courseId,
    DateTime? enrolledAt,
    EnrollmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Enrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'enrolledAt': enrolledAt.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      studentId: json['studentId'],
      courseId: json['courseId'],
      enrolledAt: DateTime.parse(json['enrolledAt']),
      status: EnrollmentStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 8)
enum EnrollmentStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  dropped,
  @HiveField(3)
  completed,
}
