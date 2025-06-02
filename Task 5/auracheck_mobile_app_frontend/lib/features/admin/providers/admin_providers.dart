import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/user.dart';
import '../../../core/models/session.dart';
import '../../../core/services/hive_service.dart';
part 'admin_providers.g.dart';

@riverpod
Future<Map<String, dynamic>> adminSystemStats(AdminSystemStatsRef ref) async {
  // Total users
  final totalUsers = HiveService.userBox.length;
  
  // Active sessions
  final activeSessions = HiveService.sessionBox.values
      .where((session) => session.status == SessionStatus.active)
      .length;
  
  // Total courses
  final totalCourses = HiveService.courseBox.length;
  
  // System health (dummy calculation)
  final systemHealth = 95; // In real app, this would be calculated based on various metrics
  
  return {
    'totalUsers': totalUsers,
    'activeSessions': activeSessions,
    'totalCourses': totalCourses,
    'systemHealth': systemHealth,
  };
}

@riverpod
Future<List<Map<String, dynamic>>> allUsers(AllUsersRef ref, {UserRole? roleFilter, String? searchQuery}) async {
  var users = HiveService.userBox.values.toList();
  
  // Apply role filter
  if (roleFilter != null) {
    users = users.where((user) => user.role == roleFilter).toList();
  }
  
  // Apply search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    users = users.where((user) =>
        user.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
        user.matriculeOrStaffId.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
  
  // Sort by name
  users.sort((a, b) => a.fullName.compareTo(b.fullName));
  
  return users.map((user) => {
    'id': user.id,
    'fullName': user.fullName,
    'email': user.email,
    'matriculeOrStaffId': user.matriculeOrStaffId,
    'role': user.role.name,
    'status': user.status.name,
    'createdAt': user.createdAt,
    'hasFacialTemplate': user.hasFacialTemplate,
  }).toList();
}

@riverpod
Future<List<Map<String, dynamic>>> allCourses(AllCoursesRef ref, {String? searchQuery}) async {
  var courses = HiveService.courseBox.values.toList();
  
  // Apply search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    courses = courses.where((course) =>
        course.courseCode.toLowerCase().contains(searchQuery.toLowerCase()) ||
        course.courseName.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
  
  // Sort by course code
  courses.sort((a, b) => a.courseCode.compareTo(b.courseCode));
  
  return courses.map((course) {
    final instructor = HiveService.userBox.get(course.instructorId);
    return {
      'id': course.id,
      'courseCode': course.courseCode,
      'courseName': course.courseName,
      'description': course.description,
      'instructorId': course.instructorId,
      'instructorName': instructor?.fullName ?? 'Unknown',
      'createdAt': course.createdAt,
    };
  }).toList();
}

@riverpod
Future<List<Map<String, dynamic>>> allGeofences(AllGeofencesRef ref, {String? searchQuery}) async {
  var geofences = HiveService.geofenceBox.values.toList();
  
  // Apply search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    geofences = geofences.where((geofence) =>
        geofence.name.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }
  
  // Sort by name
  geofences.sort((a, b) => a.name.compareTo(b.name));
  
  return geofences.map((geofence) => {
    'id': geofence.id,
    'name': geofence.name,
    'latitude': geofence.latitude,
    'longitude': geofence.longitude,
    'radius': geofence.radius,
    'isActive': geofence.isActive,
    'createdAt': geofence.createdAt,
  }).toList();
}

@riverpod
Future<List<Map<String, String>>> instructorsList(InstructorsListRef ref) async {
  final instructors = HiveService.userBox.values
      .where((user) => user.role == UserRole.instructor && user.status == UserStatus.active)
      .toList();
  
  instructors.sort((a, b) => a.fullName.compareTo(b.fullName));
  
  return instructors.map((instructor) => {
    'id': instructor.id,
    'name': instructor.fullName,
    'staffId': instructor.matriculeOrStaffId,
  }).toList();
}

@riverpod
Future<Map<String, dynamic>> courseEnrollmentDetails(CourseEnrollmentDetailsRef ref, String courseId) async {
  final course = HiveService.courseBox.get(courseId);
  if (course == null) return {};
  
  // Get enrolled students
  final enrolledStudentIds = HiveService.enrollmentBox.get('course_$courseId') as List<String>? ?? [];
  
  final enrolledStudents = <Map<String, dynamic>>[];
  for (final studentId in enrolledStudentIds) {
    final student = HiveService.userBox.get(studentId);
    if (student != null) {
      enrolledStudents.add({
        'id': student.id,
        'fullName': student.fullName,
        'matriculeNumber': student.matriculeOrStaffId,
        'email': student.email,
        'status': student.status.name,
      });
    }
  }
  
  // Sort by name
  enrolledStudents.sort((a, b) => a['fullName'].compareTo(b['fullName']));
  
  return {
    'course': {
      'id': course.id,
      'courseCode': course.courseCode,
      'courseName': course.courseName,
      'description': course.description,
    },
    'enrolledStudents': enrolledStudents,
    'totalEnrolled': enrolledStudents.length,
  };
}