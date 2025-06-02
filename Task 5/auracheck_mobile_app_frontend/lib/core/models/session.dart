import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 4)
class Session extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String courseId;
  
  @HiveField(2)
  final DateTime startTime;
  
  @HiveField(3)
  final DateTime? endTime;
  
  @HiveField(4)
  final String geofenceId;
  
  @HiveField(5)
  final SessionStatus status;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;

  Session({
    required this.id,
    required this.courseId,
    required this.startTime,
    this.endTime,
    required this.geofenceId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Session copyWith({
    String? id,
    String? courseId,
    DateTime? startTime,
    DateTime? endTime,
    String? geofenceId,
    SessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      geofenceId: geofenceId ?? this.geofenceId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == SessionStatus.active;
  bool get hasEnded => status == SessionStatus.ended;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'geofenceId': geofenceId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      courseId: json['courseId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      geofenceId: json['geofenceId'],
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 5)
enum SessionStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  active,
  @HiveField(2)
  ended,
}