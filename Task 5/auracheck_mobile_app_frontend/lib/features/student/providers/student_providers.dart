import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/session.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'student_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> activeSessionsForStudent(ActiveSessionsForStudentRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get student's enrolled courses
  final enrollments = HiveService.enrollmentBox.get(user.id) as List<String>? ?? [];
  
  // Get all active sessions
  final activeSessions = HiveService.sessionBox.values
      .where((session) => session.status == SessionStatus.active)
      .where((session) => enrollments.contains(session.courseId))
      .toList();

  // Enrich with course and geofence data
  final enrichedSessions = <Map<String, dynamic>>[];
  
  for (final session in activeSessions) {
    final course = HiveService.courseBox.get(session.courseId);
    final geofence = HiveService.geofenceBox.get(session.geofenceId);
    
    if (course != null && geofence != null) {
      enrichedSessions.add({
        'id': session.id,
        'courseId': session.courseId,
        'courseName': '${course.courseCode} - ${course.courseName}',
        'startTime': _formatTime(session.startTime),
        'location': geofence.name,
        'geofenceId': session.geofenceId,
      });
    }
  }

  return enrichedSessions;
}

@riverpod
Future<Map<String, dynamic>> studentAttendanceStats(StudentAttendanceStatsRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {'present': 0, 'absent': 0, 'total': 0, 'percentage': 0};

  // Get all attendance records for this student
  final records = HiveService.attendanceBox.values
      .where((record) => record.studentId == user.id)
      .toList();

  final present = records.where((r) => r.status == AttendanceStatus.present).length;
  final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
  final total = records.length;
  final percentage = total > 0 ? ((present / total) * 100).round() : 0;

  return {
    'present': present,
    'absent': absent,
    'total': total,
    'percentage': percentage,
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

  // Get all attendance records for this student
  var records = HiveService.attendanceBox.values
      .where((record) => record.studentId == user.id)
      .toList();

  // Apply filters
  if (courseId != null) {
    // Filter by course - need to get session IDs for the course
    final courseSessions = HiveService.sessionBox.values
        .where((session) => session.courseId == courseId)
        .map((session) => session.id)
        .toSet();
    
    records = records.where((record) => courseSessions.contains(record.sessionId)).toList();
  }

  if (startDate != null || endDate != null) {
    records = records.where((record) {
      final recordDate = record.createdAt;
      if (startDate != null && recordDate.isBefore(startDate)) return false;
      if (endDate != null && recordDate.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // Enrich with session and course data
  final enrichedRecords = <Map<String, dynamic>>[];
  
  for (final record in records) {
    final session = HiveService.sessionBox.get(record.sessionId);
    final course = session != null ? HiveService.courseBox.get(session.courseId) : null;
    
    if (session != null && course != null) {
      enrichedRecords.add({
        'id': record.id,
        'date': _formatDate(record.createdAt),
        'courseCode': course.courseCode,
        'courseName': course.courseName,
        'sessionTime': _formatTime(session.startTime),
        'status': record.status.name,
        'checkInTime': record.checkInTimestamp != null ? _formatTime(record.checkInTimestamp!) : null,
        'isOverridden': record.isOverridden,
        'overrideJustification': record.overrideJustification,
      });
    }
  }

  // Sort by date (most recent first)
  enrichedRecords.sort((a, b) => b['date'].compareTo(a['date']));

  return enrichedRecords;
}

@riverpod
Future<List<Map<String, String>>> studentEnrolledCourses(StudentEnrolledCoursesRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  // Get student's enrolled courses
  final enrollments = HiveService.enrollmentBox.get(user.id) as List<String>? ?? [];
  
  final courses = <Map<String, String>>[];
  
  for (final courseId in enrollments) {
    final course = HiveService.courseBox.get(courseId);
    if (course != null) {
      courses.add({
        'id': course.id,
        'code': course.courseCode,
        'name': course.courseName,
        'displayName': '${course.courseCode} - ${course.courseName}',
      });
    }
  }

  courses.sort((a, b) => a['code']!.compareTo(b['code']!));
  return courses;
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final year = dateTime.year;
  return '$day/$month/$year';
}