import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'student_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> activeSessionsForStudent(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get student's enrolled courses from Firebase
  final enrolledCourseIds = await FirebaseService.getStudentCourseIds(user.id);

  // Get all active sessions from Firebase
  final allActiveSessions = await FirebaseService.getActiveSessions();

  // Filter for student's enrolled courses
  final activeSessions = allActiveSessions
      .where((session) => enrolledCourseIds.contains(session.courseId))
      .toList();

  // Enrich with course and geofence data
  final enrichedSessions = <Map<String, dynamic>>[];
  
  for (final session in activeSessions) {
    final course = await FirebaseService.getCourseById(session.courseId);
    final geofence = await FirebaseService.getGeofenceById(session.geofenceId);

    if (course != null && geofence != null) {
      // Check if the student has already checked in
      final attendanceRecord = await FirebaseService.getStudentAttendanceForSession(user.id, session.id);

      enrichedSessions.add({
        'id': session.id,
        'courseId': session.courseId,
        'courseName': '${course.courseCode} - ${course.courseName}',
        'startTime': _formatTime(session.startTime),
        'location': geofence.name,
        'geofenceId': session.geofenceId,
        'hasCheckedIn': attendanceRecord?.status == AttendanceStatus.present,
      });
    }
  }

  return enrichedSessions;
}

@riverpod
Future<Map<String, dynamic>> studentAttendanceStats(StudentAttendanceStatsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'present': 0, 'absent': 0, 'total': 0, 'percentage': 0};

  // Get all attendance records for this student from Firebase
  final records = await FirebaseService.getAttendanceRecordsByStudent(user.id);

  final presentCount = records.where((record) => record.status == AttendanceStatus.present).length;
  final absentCount = records.where((record) => record.status == AttendanceStatus.absent).length;
  final total = records.length;

  double percentage = total > 0 ? (presentCount / total) * 100 : 0;

  return {
    'present': presentCount,
    'absent': absentCount,
    'total': total,
    'percentage': percentage.toStringAsFixed(1),
  };
}

@riverpod
Future<List<Map<String, dynamic>>> studentAttendanceHistory(
  StudentAttendanceHistoryRef ref, {
  String? courseId,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get all attendance records for this student from Firebase
  final records = await FirebaseService.getAttendanceRecordsByStudent(user.id);

  // Filter records by parameters if provided
  var filteredRecords = records;

  final history = <Map<String, dynamic>>[];

  for (final record in filteredRecords) {
    // Get session details
    final session = await FirebaseService.getSessionById(record.sessionId);
    if (session == null) continue;

    // Filter by course if courseId is provided
    if (courseId != null && session.courseId != courseId) {
      continue;
    }

    // Filter by date range if provided
    if (startDate != null && session.startTime.isBefore(startDate)) {
      continue;
    }
    if (endDate != null && session.startTime.isAfter(endDate)) {
      continue;
    }

    // Get course details
    final course = await FirebaseService.getCourseById(session.courseId);
    if (course == null) continue;

    history.add({
      'id': record.id,
      'sessionId': session.id,
      'courseId': course.id,
      'courseCode': course.courseCode,
      'courseName': course.courseName,
      'date': _formatDate(session.startTime),
      'time': _formatTime(session.startTime),
      'status': record.status.name,
      'isOverridden': record.isOverridden,
    });
  }

  // Sort by date descending (most recent first)
  history.sort((a, b) => b['date'].compareTo(a['date']));

  return history;
}

@riverpod
Future<List<Map<String, dynamic>>> studentEnrolledCourses(StudentEnrolledCoursesRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get student's enrolled course IDs from Firebase
  final enrolledCourseIds = await FirebaseService.getStudentCourseIds(user.id);

  // Get full course details for each enrolled course
  final enrolledCourses = <Map<String, dynamic>>[];

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

  return enrolledCourses;
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year.toString();
  return '$year-$month-$day';
}