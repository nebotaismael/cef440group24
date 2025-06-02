import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'check_in_provider.g.dart';

@riverpod
class CheckIn extends _$CheckIn {
  @override
  bool build() {
    return false;
  }

  Future<bool> validateGeofence(String sessionId, double latitude, double longitude) async {
    try {
      final session = HiveService.sessionBox.get(sessionId);
      if (session == null) return false;

      final geofence = HiveService.geofenceBox.get(session.geofenceId);
      if (geofence == null) return false;

      return geofence.containsLocation(latitude, longitude);
    } catch (e) {
      return false;
    }
  }

  Future<CheckInResult> performCheckIn(
    String sessionId,
    String imagePath,
    double latitude,
    double longitude,
  ) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        return CheckInResult.failure('User not authenticated');
      }

      final session = HiveService.sessionBox.get(sessionId);
      if (session == null) {
        return CheckInResult.failure('Session not found');
      }

      final course = HiveService.courseBox.get(session.courseId);
      if (course == null) {
        return CheckInResult.failure('Course not found');
      }

      // Validate geofence again
      final isInGeofence = await validateGeofence(sessionId, latitude, longitude);
      if (!isInGeofence) {
        return CheckInResult.failure('You are not within the designated class area');
      }

      // Simulate facial recognition processing
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real implementation, this would:
      // 1. Extract facial features from the image
      // 2. Compare with stored template
      // 3. Verify similarity threshold
      
      // For demo purposes, simulate success if user has facial template
      if (!user.hasFacialTemplate) {
        return CheckInResult.failure('Facial template not found. Please complete enrollment first.');
      }

      // Create attendance record
      const uuid = Uuid();
      final now = DateTime.now();
      final attendanceRecord = AttendanceRecord(
        id: uuid.v4(),
        studentId: user.id,
        sessionId: sessionId,
        status: AttendanceStatus.present,
        checkInTimestamp: now,
        createdAt: now,
        updatedAt: now,
      );

      await HiveService.attendanceBox.put(attendanceRecord.id, attendanceRecord);

      return CheckInResult.success(
        '${course.courseCode} - ${course.courseName}',
        now,
      );
    } catch (e) {
      return CheckInResult.failure('An error occurred during check-in: $e');
    }
  }
}

class CheckInResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? courseName;
  final DateTime? checkInTime;

  CheckInResult._({
    required this.isSuccess,
    this.errorMessage,
    this.courseName,
    this.checkInTime,
  });

  factory CheckInResult.success(String courseName, DateTime checkInTime) {
    return CheckInResult._(
      isSuccess: true,
      courseName: courseName,
      checkInTime: checkInTime,
    );
  }

  factory CheckInResult.failure(String message) {
    return CheckInResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}