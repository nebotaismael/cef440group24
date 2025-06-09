import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String fullName;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String matriculeOrStaffId;
  
  @HiveField(4)
  final UserRole role;
  
  @HiveField(5)
  final UserStatus status;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;
  
  @HiveField(8)
  final bool hasFacialTemplate;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.matriculeOrStaffId,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.hasFacialTemplate = false,
  });

  // Create a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return User(
      id: document.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      matriculeOrStaffId: data['matriculeOrStaffId'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.toString() == data['role'],
        orElse: () => UserRole.student,
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => UserStatus.inactive,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      hasFacialTemplate: data['hasFacialTemplate'] ?? false,
    );
  }

  // Convert User to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'matriculeOrStaffId': matriculeOrStaffId,
      'role': role.toString(),
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'hasFacialTemplate': hasFacialTemplate,
    };
  }

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? matriculeOrStaffId,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasFacialTemplate,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      matriculeOrStaffId: matriculeOrStaffId ?? this.matriculeOrStaffId,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasFacialTemplate: hasFacialTemplate ?? this.hasFacialTemplate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'matriculeOrStaffId': matriculeOrStaffId,
      'role': role.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasFacialTemplate': hasFacialTemplate,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      matriculeOrStaffId: json['matriculeOrStaffId'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      status: UserStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      hasFacialTemplate: json['hasFacialTemplate'] ?? false,
    );
  }
}

@HiveType(typeId: 10)
enum UserRole {
  @HiveField(0)
  student,
  @HiveField(1)
  instructor,
  @HiveField(2)
  admin
}

@HiveType(typeId: 11)
enum UserStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive
}