
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/firebase_service.dart';
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
      // Get session from Firebase
      final session = await FirebaseService.getSessionById(sessionId);
      if (session == null) return false;

      // Get geofence from Firebase
      final geofence = await FirebaseService.getGeofenceById(session.geofenceId);
      if (geofence == null) return false;

      // Check if student is within the geofence radius
      return geofence.isWithinRadius(latitude, longitude);
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
      state = true; // Set loading state

      final user = ref.read(currentUserProvider);
      if (user == null) {
        return CheckInResult.failure('User not authenticated');
      }

      // Get session from Firebase
      final session = await FirebaseService.getSessionById(sessionId);
      if (session == null) {
        return CheckInResult.failure('Session not found');
      }

      // Get course from Firebase
      final course = await FirebaseService.getCourseById(session.courseId);
      if (course == null) {
        return CheckInResult.failure('Course not found');
      }

      // Check if student is already checked in for this session
      final existingRecord = await FirebaseService.getStudentAttendanceForSession(
        user.id,
        sessionId
      );

      if (existingRecord != null) {
        return CheckInResult.failure('Already checked in for this session');
      }

      // Validate geofence
      final isWithinGeofence = await validateGeofence(sessionId, latitude, longitude);
      if (!isWithinGeofence) {
        return CheckInResult.failure('You are not within the required location');
      }

      // Validate facial recognition
      final isRecognized = await _validateFacialRecognition(user.id, imagePath);
      if (!isRecognized) {
        return CheckInResult.failure('Facial recognition failed');
      }

      // Create attendance record in Firebase
      final now = DateTime.now();
      final uuid = const Uuid();
      final record = AttendanceRecord(
        id: uuid.v4(),
        studentId: user.id,
        sessionId: sessionId,
        status: AttendanceStatus.present,
        checkInTimestamp: now,
        createdAt: now,
        updatedAt: now,
      );

      // Save record to Firebase
      await FirebaseService.createAttendanceRecord(record);

      return CheckInResult.success(
        'Successfully checked in to ${course.courseCode}',
        courseName: course.courseName,
        checkInTime: now,
      );
    } catch (e) {
      return CheckInResult.failure('An error occurred: ${e.toString()}');
    } finally {
      state = false; // Reset loading state
    }
  }

  Future<bool> _validateFacialRecognition(String userId, String imagePath) async {
    try {
      // In a real app, we would:
      // 1. Get the stored template from Firebase
      // 2. Process the new image to extract features
      // 3. Compare the features to validate identity

      // For demo purposes, we'll simulate success after retrieving the template
      final template = await FirebaseService.getFacialTemplate(userId);

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 1));

      // If we have a template, consider it a success
      return template != null;
    } catch (e) {
      return false;
    }
  }
}

class CheckInResult {
  final bool success;
  final String message;
  final String? courseName;
  final DateTime? checkInTime;

  CheckInResult.success(this.message, {
    this.courseName,
    this.checkInTime,
  }) : success = true;

  CheckInResult.failure(this.message)
      : success = false,
        courseName = null,
        checkInTime = null;

  // Add getters for backward compatibility
  bool get isSuccess => success;
  String get errorMessage => message;
}