import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'course.g.dart';

@HiveType(typeId: 3)
class Course extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String courseCode;
  
  @HiveField(2)
  final String courseName;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String instructorId;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.description,
    required this.instructorId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Course from a Firestore document
  factory Course.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Course(
      id: document.id,
      courseCode: data['courseCode'] ?? '',
      courseName: data['courseName'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert Course to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'instructorId': instructorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Course copyWith({
    String? id,
    String? courseCode,
    String? courseName,
    String? description,
    String? instructorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'instructorId': instructorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      courseCode: json['courseCode'],
      courseName: json['courseName'],
      description: json['description'],
      instructorId: json['instructorId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}