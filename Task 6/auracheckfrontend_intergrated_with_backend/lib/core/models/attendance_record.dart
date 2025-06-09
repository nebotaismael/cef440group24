import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance_record.g.dart';

@HiveType(typeId: 6)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String studentId;
  
  @HiveField(2)
  final String sessionId;
  
  @HiveField(3)
  final AttendanceStatus status;
  
  @HiveField(4)
  final DateTime? checkInTimestamp;
  
  @HiveField(5)
  final String? overrideJustification;
  
  @HiveField(6)
  final String? overrideBy;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.status,
    this.checkInTimestamp,
    this.overrideJustification,
    this.overrideBy,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOverridden => overrideBy != null && overrideJustification != null;

  // Create an AttendanceRecord from a Firestore document
  factory AttendanceRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return AttendanceRecord(
      id: document.id,
      studentId: data['studentId'] ?? '',
      sessionId: data['sessionId'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      checkInTimestamp: data['checkInTimestamp'] != null
        ? (data['checkInTimestamp'] as Timestamp).toDate()
        : null,
      overrideJustification: data['overrideJustification'],
      overrideBy: data['overrideBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Convert AttendanceRecord to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'sessionId': sessionId,
      'status': status.toString(),
      'checkInTimestamp': checkInTimestamp != null ? Timestamp.fromDate(checkInTimestamp!) : null,
      'overrideJustification': overrideJustification,
      'overrideBy': overrideBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'sessionId': sessionId,
      'status': status.name,
      'checkInTimestamp': checkInTimestamp?.toIso8601String(),
      'overrideJustification': overrideJustification,
      'overrideBy': overrideBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['studentId'],
      sessionId: json['sessionId'],
      status: AttendanceStatus.values.firstWhere((e) => e.name == json['status']),
      checkInTimestamp: json['checkInTimestamp'] != null ? DateTime.parse(json['checkInTimestamp']) : null,
      overrideJustification: json['overrideJustification'],
      overrideBy: json['overrideBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? sessionId,
    AttendanceStatus? status,
    DateTime? checkInTimestamp,
    String? overrideJustification,
    String? overrideBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      checkInTimestamp: checkInTimestamp ?? this.checkInTimestamp,
      overrideJustification: overrideJustification ?? this.overrideJustification,
      overrideBy: overrideBy ?? this.overrideBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 7)
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent
}