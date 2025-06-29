import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/auracheck_api_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'check_in_provider.g.dart';

enum CheckInStep {
  initializing,
  acquiringLocation,
  validatingLocation,
  initializingCamera,
  readyToCapture,
  processing,
  complete,
  error,
}

class CheckInResult {
  final bool success;
  final String message;
  final String? attendanceId;
  final List<VerificationDetail>? verificationDetails;

  CheckInResult.success(this.message, {this.attendanceId, this.verificationDetails}) : success = true;
  CheckInResult.failure(this.message) : success = false, attendanceId = null, verificationDetails = null;

  // Add getters for backward compatibility with your existing UI
  bool get isSuccess => success;
  String get errorMessage => success ? '' : message;
  String get courseName => success ? 'Course' : ''; // Default value, you can customize
}

@riverpod
class CheckIn extends _$CheckIn {
  @override
  bool build() {
    return false;
  }

  Future<bool> validateGeofence(String sessionId, double latitude, double longitude) async {
    try {
      // Get session from Firebase using your existing service
      final session = await FirebaseService.getSessionById(sessionId);
      if (session == null) return false;

      // Get geofence from Firebase using your existing service
      final geofence = await FirebaseService.getGeofenceById(session.geofenceId);
      if (geofence == null) return false;

      // Check if student is within the geofence radius using your existing method
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

      final user = ref.read(authProvider).value;
      if (user == null) {
        return CheckInResult.failure('User not authenticated');
      }

      // Get session from Firebase using your existing service
      final session = await FirebaseService.getSessionById(sessionId);
      if (session == null) {
        return CheckInResult.failure('Session not found');
      }

      final File imageFile = File(imagePath);

      // Step 1: Try AuraCheck API for multi-factor attendance verification
      final authorizedLocations = [
        AuthorizedLocation(
          latitude: latitude,
          longitude: longitude,
          radius: 100.0, // 100 meter radius
          name: 'Class Location', // Using default name since Session model doesn't have title
        ),
      ];

      final auraCheckResponse = await AuraCheckApiService.verifyAttendance(
        imageFile: imageFile,
        sessionId: sessionId,
        latitude: latitude,
        longitude: longitude,
        authorizedLocations: authorizedLocations,
        locationId: session.geofenceId,
      );

      if (auraCheckResponse.success) {
        final attendanceData = auraCheckResponse.data!;

        // Step 2: Store attendance record in Firebase using your existing model and service
        final attendanceRecord = AttendanceRecord(
          id: attendanceData.attendanceId,
          studentId: user.id,
          sessionId: sessionId,
          status: attendanceData.verified ? AttendanceStatus.present : AttendanceStatus.absent,
          checkInTimestamp: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Use your existing Firebase service method - createAttendanceRecord not saveAttendanceRecord
        await FirebaseService.createAttendanceRecord(attendanceRecord);

        return CheckInResult.success(
          attendanceData.verified ? 'Attendance verified successfully!' : 'Attendance verification failed',
          attendanceId: attendanceData.attendanceId,
          verificationDetails: attendanceData.verificationDetails,
        );
      } else {
        // Fallback to existing Firebase-only check-in if AuraCheck fails
        return await _performFirebaseCheckIn(sessionId, imagePath, latitude, longitude);
      }
    } catch (e) {
      // Fallback to existing Firebase-only check-in on error
      return await _performFirebaseCheckIn(sessionId, imagePath, latitude, longitude);
    } finally {
      state = false;
    }
  }

  // Fallback method using your existing Firebase functionality
  Future<CheckInResult> _performFirebaseCheckIn(
    String sessionId,
    String imagePath,
    double latitude,
    double longitude,
  ) async {
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        return CheckInResult.failure('User not authenticated');
      }

      // Validate geofence using existing logic
      final isInGeofence = await validateGeofence(sessionId, latitude, longitude);
      if (!isInGeofence) {
        return CheckInResult.failure('You are not within the designated class area');
      }

      // Create attendance record using your existing model
      final attendanceRecord = AttendanceRecord(
        id: const Uuid().v4(),
        studentId: user.id,
        sessionId: sessionId,
        status: AttendanceStatus.present,
        checkInTimestamp: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Use your existing Firebase service method - createAttendanceRecord
      final recordId = await FirebaseService.createAttendanceRecord(attendanceRecord);

      return CheckInResult.success(
        'Attendance marked successfully (location verified)',
        attendanceId: recordId,
      );
    } catch (e) {
      return CheckInResult.failure('Check-in failed: $e');
    }
  }
}
