import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/user.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/firebase_service.dart';
part 'admin_providers.g.dart';

@riverpod
Future<Map<String, dynamic>> adminSystemStats(AdminSystemStatsRef ref) async {
  // Get users from Firebase
  final users = await FirebaseService.getAllUsers();

  // Get active sessions from Firebase
  final activeSessions = await FirebaseService.getActiveSessions();

  // Get courses from Firebase
  final courses = await FirebaseService.getAllCourses();

  // Get geofences from Firebase
  final geofences = await FirebaseService.getAllGeofences();

  // System health (dummy calculation)
  final systemHealth = 95; // In real app, this would be calculated based on various metrics
  
  return {
    'totalUsers': users.length,
    'activeSessions': activeSessions.length,
    'totalCourses': courses.length,
    'totalGeofences': geofences.length,
    'systemHealth': systemHealth,
  };
}

@riverpod
Future<List<Map<String, dynamic>>> allUsers(AllUsersRef ref, {UserRole? roleFilter, String? searchQuery}) async {
  // Get users from Firebase
  List<User> users = await FirebaseService.getAllUsers();

  // Apply role filter
  if (roleFilter != null) {
    users = users.where((user) => user.role == roleFilter).toList();
  }
  
  // Apply search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    users = users.where((user) =>
        user.fullName.toLowerCase().contains(query) ||
        user.email.toLowerCase().contains(query) ||
        user.matriculeOrStaffId.toLowerCase().contains(query)
    ).toList();
  }
  
  // Sort by name
  users.sort((a, b) => a.fullName.compareTo(b.fullName));
  
  // Map to UI format
  return users.map((user) => {
    'id': user.id,
    'fullName': user.fullName,
    'email': user.email,
    'matriculeOrStaffId': user.matriculeOrStaffId,
    'role': user.role.name,
    'status': user.status.name,
    'hasFacialTemplate': user.hasFacialTemplate,
    'createdAt': user.createdAt.toIso8601String(),
  }).toList();
}

@riverpod
Future<List<Map<String, dynamic>>> allCourses(AllCoursesRef ref, {String? searchQuery}) async {
  // Get courses from Firebase
  var courses = await FirebaseService.getAllCourses();

  // Apply search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    courses = courses.where((course) =>
        course.courseCode.toLowerCase().contains(query) ||
        course.courseName.toLowerCase().contains(query)
    ).toList();
  }
  
  // Build detailed course list
  final enrichedCourses = <Map<String, dynamic>>[];

  for (final course in courses) {
    // Get instructor
    final instructor = await FirebaseService.getUserById(course.instructorId);

    // Get enrolled students count
    final enrolledStudents = await FirebaseService.getEnrolledStudentIds(course.id);

    // Get total sessions
    final sessions = await FirebaseService.getSessionsByCourse(course.id);

    enrichedCourses.add({
      'id': course.id,
      'courseCode': course.courseCode,
      'courseName': course.courseName,
      'description': course.description,
      'instructorId': course.instructorId,
      'instructorName': instructor?.fullName ?? 'Unknown',
      'enrolledCount': enrolledStudents.length,
      'sessionCount': sessions.length,
      'createdAt': course.createdAt.toIso8601String(),
    });
  }

  return enrichedCourses;
}

@riverpod
Future<List<Map<String, dynamic>>> allGeofences(AllGeofencesRef ref, {bool? activeOnly, String? searchQuery}) async {
  // Get geofences from Firebase
  var geofences = await FirebaseService.getAllGeofences();

  // Filter by active status if requested
  if (activeOnly == true) {
    geofences = geofences.where((geofence) => geofence.isActive).toList();
  }
  
  // Apply search filter
  if (searchQuery != null && searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    geofences = geofences.where((geofence) =>
        geofence.name.toLowerCase().contains(query)
    ).toList();
  }

  // Map to UI format
  return geofences.map((geofence) => {
    'id': geofence.id,
    'name': geofence.name,
    'latitude': geofence.latitude,
    'longitude': geofence.longitude,
    'radius': geofence.radius,
    'isActive': geofence.isActive,
    'createdAt': geofence.createdAt.toIso8601String(),
  }).toList();
}

@riverpod
Future<Map<String, dynamic>> userDetails(UserDetailsRef ref, String userId) async {
  // Get user from Firebase
  final user = await FirebaseService.getUserById(userId);
  if (user == null) return {};

  // Get courses (if instructor)
  List<Map<String, dynamic>> courses = [];
  if (user.role == UserRole.instructor) {
    final instructorCourses = await FirebaseService.getCoursesByInstructor(userId);
    courses = instructorCourses.map((course) => {
      'id': course.id,
      'courseCode': course.courseCode,
      'courseName': course.courseName,
    }).toList();
  }

  // Get enrolled courses (if student)
  List<Map<String, dynamic>> enrolledCourses = [];
  if (user.role == UserRole.student) {
    final enrolledCourseIds = await FirebaseService.getStudentCourseIds(userId);

    for (final courseId in enrolledCourseIds) {
      final course = await FirebaseService.getCourseById(courseId);
      if (course != null) {
        enrolledCourses.add({
          'id': course.id,
          'courseCode': course.courseCode,
          'courseName': course.courseName,
        });
      }
    }
  }

  // Get attendance statistics (if student)
  Map<String, dynamic> attendanceStats = {};
  if (user.role == UserRole.student) {
    final records = await FirebaseService.getAttendanceRecordsByStudent(userId);

    final presentCount = records.where((record) => record.status == AttendanceStatus.present).length;
    final totalCount = records.length;

    attendanceStats = {
      'present': presentCount,
      'total': totalCount,
      'percentage': totalCount > 0 ? (presentCount / totalCount * 100).toStringAsFixed(1) : '0.0',
    };
  }

  return {
    'id': user.id,
    'fullName': user.fullName,
    'email': user.email,
    'matriculeOrStaffId': user.matriculeOrStaffId,
    'role': user.role.name,
    'status': user.status.name,
    'hasFacialTemplate': user.hasFacialTemplate,
    'createdAt': user.createdAt.toIso8601String(),
    'updatedAt': user.updatedAt.toIso8601String(),
    'courses': courses,
    'enrolledCourses': enrolledCourses,
    'attendanceStats': attendanceStats,
  };
}

@riverpod
Future<Map<String, dynamic>> courseDetails(CourseDetailsRef ref, String courseId) async {
  // Get course from Firebase
  final course = await FirebaseService.getCourseById(courseId);
  if (course == null) return {};
  
  // Get instructor
  final instructor = await FirebaseService.getUserById(course.instructorId);

  // Get enrolled students
  final enrolledStudentIds = await FirebaseService.getEnrolledStudentIds(courseId);
  final enrolledStudents = <Map<String, dynamic>>[];

  for (final studentId in enrolledStudentIds) {
    final student = await FirebaseService.getUserById(studentId);
    if (student != null) {
      enrolledStudents.add({
        'id': student.id,
        'fullName': student.fullName,
        'matriculeOrStaffId': student.matriculeOrStaffId,
      });
    }
  }
  
  // Get sessions
  final sessions = await FirebaseService.getSessionsByCourse(courseId);
  final sessionData = sessions.map((session) => {
    'id': session.id,
    'startTime': session.startTime.toIso8601String(),
    'endTime': session.endTime?.toIso8601String(),
    'status': session.status.name,
  }).toList();

  return {
    'id': course.id,
    'courseCode': course.courseCode,
    'courseName': course.courseName,
    'description': course.description,
    'instructorId': course.instructorId,
    'instructorName': instructor?.fullName ?? 'Unknown',
    'createdAt': course.createdAt.toIso8601String(),
    'updatedAt': course.updatedAt.toIso8601String(),
    'enrolledStudents': enrolledStudents,
    'sessions': sessionData,
  };
}

@riverpod
Future<List<Map<String, dynamic>>> instructorsList(InstructorsListRef ref) async {
  // Get instructor users from Firebase
  final instructors = await FirebaseService.getUsersByRole(UserRole.instructor);

  // Map to UI format
  return instructors.map((instructor) => {
    'id': instructor.id,
    'fullName': instructor.fullName,
    'email': instructor.email,
    'matriculeOrStaffId': instructor.matriculeOrStaffId,
  }).toList();
}

@riverpod
Future<Map<String, dynamic>> courseEnrollmentDetails(CourseEnrollmentDetailsRef ref, String courseId) async {
  // Get course details from Firebase
  final course = await FirebaseService.getCourseById(courseId);
  if (course == null) {
    throw Exception('Course not found');
  }

  // Get enrolled students
  final enrolledStudentIds = await FirebaseService.getEnrolledStudentIds(courseId);

  // Get student details for each enrolled student
  final enrolledStudents = <Map<String, dynamic>>[];
  for (final studentId in enrolledStudentIds) {
    final student = await FirebaseService.getUserById(studentId);
    if (student != null) {
      enrolledStudents.add({
        'id': student.id,
        'fullName': student.fullName,
        'matriculeNumber': student.matriculeOrStaffId,
        'email': student.email,
        'hasFacialTemplate': student.hasFacialTemplate,
      });
    }
  }

  // Build and return the enrollment details
  return {
    'course': {
      'id': course.id,
      'courseCode': course.courseCode,
      'courseName': course.courseName,
      'instructorId': course.instructorId,
    },
    'enrolledStudents': enrolledStudents,
    'totalEnrolled': enrolledStudents.length,
  };
}
