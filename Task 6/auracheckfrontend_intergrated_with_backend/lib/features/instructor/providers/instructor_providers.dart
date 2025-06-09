import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'instructor_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> instructorCourses(InstructorCoursesRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get instructor's courses from Firebase
  final courses = await FirebaseService.getCoursesByInstructor(user.id);

  return courses.map((course) => {
    'id': course.id,
    'courseCode': course.courseCode,
    'courseName': course.courseName,
    'description': course.description,
  }).toList();
}

@riverpod
Future<List<Map<String, dynamic>>> instructorActiveSessions(InstructorActiveSessionsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get instructor's courses from Firebase
  final courses = await FirebaseService.getCoursesByInstructor(user.id);
  final instructorCourses = courses.map((course) => course.id).toSet();

  // Get active sessions from Firebase
  final allActiveSessions = await FirebaseService.getActiveSessions();

  // Filter for instructor's courses
  final activeSessions = allActiveSessions
      .where((session) => instructorCourses.contains(session.courseId))
      .toList();

  final enrichedSessions = <Map<String, dynamic>>[];

  for (final session in activeSessions) {
    final course = await FirebaseService.getCourseById(session.courseId);
    final geofence = await FirebaseService.getGeofenceById(session.geofenceId);

    if (course != null && geofence != null) {
      // Get attendance stats for this session from Firebase
      final attendanceRecords = await FirebaseService.getAttendanceRecordsBySession(session.id);

      final presentCount = attendanceRecords
          .where((record) => record.status == AttendanceStatus.present)
          .length;
      
      // Get total enrolled students for this course from Firebase
      final enrolledStudents = await FirebaseService.getEnrolledStudentIds(course.id);

      enrichedSessions.add({
        'id': session.id,
        'courseId': session.courseId,
        'courseName': '${course.courseCode} - ${course.courseName}',
        'startTime': _formatTime(session.startTime),
        'location': geofence.name,
        'presentCount': presentCount,
        'totalStudents': enrolledStudents.length,
      });
    }
  }

  return enrichedSessions;
}

@riverpod
Future<Map<String, dynamic>> instructorTodayStats(InstructorTodayStatsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'sessionsToday': 0, 'totalAttendance': 0, 'averageRate': 0};

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // Get instructor's courses from Firebase
  final courses = await FirebaseService.getCoursesByInstructor(user.id);
  final instructorCourses = courses.map((course) => course.id).toSet();

  // We'll need to query all sessions for today and filter them
  // For a production app, you'd add a date-based query to Firestore directly
  final allSessions = await Future.wait(instructorCourses.map(
    (courseId) => FirebaseService.getSessionsByCourse(courseId)
  ));

  final todaySessions = allSessions
      .expand((sessions) => sessions)
      .where((session) =>
          session.startTime.isAfter(startOfDay) &&
          session.startTime.isBefore(endOfDay))
      .toList();

  int totalAttendance = 0;
  int totalExpected = 0;

  // Process each session to get attendance data
  for (final session in todaySessions) {
    final attendanceRecords = await FirebaseService.getAttendanceRecordsBySession(session.id);
    final enrolledStudents = await FirebaseService.getEnrolledStudentIds(session.courseId);

    totalAttendance += attendanceRecords
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    totalExpected += enrolledStudents.length;
  }

  double averageRate = totalExpected > 0 ? (totalAttendance / totalExpected) * 100 : 0;

  return {
    'sessionsToday': todaySessions.length,
    'totalAttendance': totalAttendance,
    'averageRate': averageRate.toStringAsFixed(1),
  };
}

@riverpod
Future<Map<String, dynamic>> sessionDetails(SessionDetailsRef ref, String sessionId) async {
  final session = await FirebaseService.getSessionById(sessionId);
  if (session == null) return {};

  final course = await FirebaseService.getCourseById(session.courseId);
  final geofence = await FirebaseService.getGeofenceById(session.geofenceId);

  if (course == null || geofence == null) return {};

  // Get enrolled students from Firebase
  final enrolledStudentIds = await FirebaseService.getEnrolledStudentIds(course.id);

  // Get attendance records from Firebase
  final attendanceRecords = await FirebaseService.getAttendanceRecordsBySession(sessionId);

  // Build student list with attendance status
  final students = <Map<String, dynamic>>[];
  
  for (final studentId in enrolledStudentIds) {
    final student = await FirebaseService.getUserById(studentId);
    if (student != null) {
      final attendanceRecord = attendanceRecords
          .where((record) => record.studentId == studentId)
          .firstOrNull;

      students.add({
        'id': student.id,
        'fullName': student.fullName,
        'matriculeNumber': student.matriculeOrStaffId,
        'status': attendanceRecord?.status.name ?? 'absent',
        'checkInTime': attendanceRecord?.checkInTimestamp != null 
            ? _formatTime(attendanceRecord!.checkInTimestamp!) 
            : null,
        'isOverridden': attendanceRecord?.isOverridden ?? false,
        'overrideJustification': attendanceRecord?.overrideJustification,
      });
    }
  }

  // Sort students by name
  students.sort((a, b) => a['fullName'].compareTo(b['fullName']));

  return {
    'sessionId': session.id,
    'courseCode': course.courseCode,
    'courseName': course.courseName,
    'startTime': _formatTime(session.startTime),
    'endTime': session.endTime != null ? _formatTime(session.endTime!) : null,
    'location': geofence.name,
    'status': session.status.name,
    'students': students,
    'totalStudents': students.length,
    'presentCount': students.where((s) => s['status'] == 'present').length,
    'absentCount': students.where((s) => s['status'] == 'absent').length,
  };
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}