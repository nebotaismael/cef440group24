import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/session.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'instructor_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> instructorCourses(InstructorCoursesRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final courses = HiveService.courseBox.values
      .where((course) => course.instructorId == user.id)
      .toList();

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

  // Get instructor's courses
  final instructorCourses = HiveService.courseBox.values
      .where((course) => course.instructorId == user.id)
      .map((course) => course.id)
      .toSet();

  // Get active sessions for instructor's courses
  final activeSessions = HiveService.sessionBox.values
      .where((session) => session.status == SessionStatus.active)
      .where((session) => instructorCourses.contains(session.courseId))
      .toList();

  final enrichedSessions = <Map<String, dynamic>>[];

  for (final session in activeSessions) {
    final course = HiveService.courseBox.get(session.courseId);
    final geofence = HiveService.geofenceBox.get(session.geofenceId);
    
    if (course != null && geofence != null) {
      // Get attendance stats for this session
      final attendanceRecords = HiveService.attendanceBox.values
          .where((record) => record.sessionId == session.id)
          .toList();
      
      final presentCount = attendanceRecords
          .where((record) => record.status == AttendanceStatus.present)
          .length;
      
      // Get total enrolled students for this course
      final enrolledStudents = HiveService.enrollmentBox.get('course_${course.id}') as List<String>? ?? [];

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

  // Get instructor's courses
  final instructorCourses = HiveService.courseBox.values
      .where((course) => course.instructorId == user.id)
      .map((course) => course.id)
      .toSet();

  // Get today's sessions
  final todaySessions = HiveService.sessionBox.values
      .where((session) => instructorCourses.contains(session.courseId))
      .where((session) => session.startTime.isAfter(startOfDay) && session.startTime.isBefore(endOfDay))
      .toList();

  int totalAttendance = 0;
  int totalExpected = 0;

  for (final session in todaySessions) {
    final attendanceRecords = HiveService.attendanceBox.values
        .where((record) => record.sessionId == session.id)
        .toList();
    
    final presentCount = attendanceRecords
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    
    final enrolledStudents = HiveService.enrollmentBox.get('course_${session.courseId}') as List<String>? ?? [];
    
    totalAttendance += presentCount;
    totalExpected += enrolledStudents.length;
  }

  final averageRate = totalExpected > 0 ? ((totalAttendance / totalExpected) * 100).round() : 0;

  return {
    'sessionsToday': todaySessions.length,
    'totalAttendance': totalAttendance,
    'averageRate': averageRate,
  };
}

@riverpod
Future<Map<String, dynamic>> sessionDetails(SessionDetailsRef ref, String sessionId) async {
  final session = HiveService.sessionBox.get(sessionId);
  if (session == null) return {};

  final course = HiveService.courseBox.get(session.courseId);
  final geofence = HiveService.geofenceBox.get(session.geofenceId);
  
  if (course == null || geofence == null) return {};

  // Get enrolled students
  final enrolledStudents = HiveService.enrollmentBox.get('course_${course.id}') as List<String>? ?? [];
  
  // Get attendance records
  final attendanceRecords = HiveService.attendanceBox.values
      .where((record) => record.sessionId == sessionId)
      .toList();

  // Build student list with attendance status
  final students = <Map<String, dynamic>>[];
  
  for (final studentId in enrolledStudents) {
    final student = HiveService.userBox.get(studentId);
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