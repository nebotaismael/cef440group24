import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/firebase_service.dart';
import '../services/dummy_data_service.dart';
import '../services/hive_service.dart';
import 'package:flutter/foundation.dart';

class FirebaseMigrationService {
  static bool _migrated = false;

  /// Migrates all data from local Hive to Firebase
  static Future<void> migrateDataToFirebase() async {
    if (_migrated) return; // Prevent multiple migrations

    try {
      // Initialize Firebase if not already initialized
      await FirebaseService.initializeFirebase();

      // Ensure dummy data is initialized in Hive
      await DummyDataService.initializeDummyData();

      // Migrate in sequence to maintain relationships
      await _migrateUsers();
      await _migrateGeofences();
      await _migrateCourses();
      await _migrateEnrollments();
      await _migrateSessions();
      await _migrateAttendanceRecords();

      _migrated = true;
      debugPrint('✅ Data migration to Firebase completed successfully');
    } catch (e) {
      debugPrint('❌ Error during Firebase migration: $e');
      rethrow;
    }
  }

  /// Migrate users from Hive to Firebase
  static Future<void> _migrateUsers() async {
    debugPrint('Migrating users to Firebase...');

    // Get all users from Hive
    final users = HiveService.userBox.values.toList();

    for (final user in users) {
      try {
        // Check if user already exists in Firebase
        final existingUser = await FirebaseService.getUserByIdentifier(user.email);
        if (existingUser != null) {
          debugPrint('User ${user.fullName} already exists in Firebase, skipping...');
          continue;
        }

        // Create Firebase Auth user
        final authResult = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: user.matriculeOrStaffId, // Use ID as initial password
        );

        // Create user in Firestore with matching ID
        final updatedUser = user.copyWith(id: authResult.user!.uid);
        await FirebaseService.usersCollection.doc(updatedUser.id).set(updatedUser.toFirestore());

        debugPrint('Migrated user: ${user.fullName}');
      } catch (e) {
        // If the user already exists but we couldn't find them, handle that case
        if (e is auth.FirebaseAuthException && e.code == 'email-already-in-use') {
          debugPrint('User with email ${user.email} already exists in Firebase Auth.');

          // Try to sign in to get the UID
          try {
            final credential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
              email: user.email,
              password: user.matriculeOrStaffId,
            );

            // Update Firestore document
            final updatedUser = user.copyWith(id: credential.user!.uid);
            await FirebaseService.usersCollection.doc(updatedUser.id).set(updatedUser.toFirestore());
            debugPrint('Updated existing user: ${user.fullName}');
          } catch (signInError) {
            debugPrint('Error signing in to update user: $signInError');
          }
        } else {
          debugPrint('Error migrating user ${user.fullName}: $e');
        }
      }
    }

    debugPrint('✓ Users migration completed');
  }

  /// Migrate geofences from Hive to Firebase
  static Future<void> _migrateGeofences() async {
    debugPrint('Migrating geofences to Firebase...');

    // Get all geofences from Hive
    final geofences = HiveService.geofenceBox.values.toList();

    for (final geofence in geofences) {
      try {
        // Check if geofence already exists
        final querySnapshot = await FirebaseService.geofencesCollection
            .where('name', isEqualTo: geofence.name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('Geofence ${geofence.name} already exists, skipping...');
          continue;
        }

        // Create new geofence in Firebase
        await FirebaseService.geofencesCollection.doc(geofence.id).set(geofence.toFirestore());

        debugPrint('Migrated geofence: ${geofence.name}');
      } catch (e) {
        debugPrint('Error migrating geofence ${geofence.name}: $e');
      }
    }

    debugPrint('✓ Geofences migration completed');
  }

  /// Migrate courses from Hive to Firebase
  static Future<void> _migrateCourses() async {
    debugPrint('Migrating courses to Firebase...');

    // Get all courses from Hive
    final courses = HiveService.courseBox.values.toList();

    for (final course in courses) {
      try {
        // Check if course already exists
        final querySnapshot = await FirebaseService.coursesCollection
            .where('courseCode', isEqualTo: course.courseCode)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('Course ${course.courseCode} already exists, skipping...');
          continue;
        }

        // Create new course in Firebase
        await FirebaseService.coursesCollection.doc(course.id).set(course.toFirestore());

        debugPrint('Migrated course: ${course.courseName}');
      } catch (e) {
        debugPrint('Error migrating course ${course.courseName}: $e');
      }
    }

    debugPrint('✓ Courses migration completed');
  }

  /// Migrate enrollments from Hive to Firebase
  static Future<void> _migrateEnrollments() async {
    debugPrint('Migrating enrollments to Firebase...');

    try {
      // Get enrollments from Hive
      final enrollmentBox = HiveService.enrollmentBox;
      final Map<dynamic, dynamic> enrollments = enrollmentBox.toMap();

      for (final entry in enrollments.entries) {
        final courseId = entry.key;
        final studentIds = entry.value as List<dynamic>;

        for (final studentId in studentIds) {
          try {
            // Enroll student in course
            await FirebaseService.enrollmentsCollection.add({
              'courseId': courseId,
              'studentId': studentId,
              'enrolledAt': DateTime.now().toUtc(),
            });
          } catch (e) {
            debugPrint('Error migrating enrollment for student $studentId in course $courseId: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error during enrollment migration: $e');
    }

    debugPrint('✓ Enrollments migration completed');
  }

  /// Migrate sessions from Hive to Firebase
  static Future<void> _migrateSessions() async {
    debugPrint('Migrating sessions to Firebase...');

    // Get all sessions from Hive
    final sessions = HiveService.sessionBox.values.toList();

    for (final session in sessions) {
      try {
        // Check if session already exists (by course and start time)
        final querySnapshot = await FirebaseService.sessionsCollection
            .where('courseId', isEqualTo: session.courseId)
            .where('startTime', isEqualTo: session.startTime)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('Session for course ${session.courseId} at ${session.startTime} already exists, skipping...');
          continue;
        }

        // Create new session in Firebase
        await FirebaseService.sessionsCollection.doc(session.id).set(session.toFirestore());

        debugPrint('Migrated session: ${session.id}');
      } catch (e) {
        debugPrint('Error migrating session ${session.id}: $e');
      }
    }

    debugPrint('✓ Sessions migration completed');
  }

  /// Migrate attendance records from Hive to Firebase
  static Future<void> _migrateAttendanceRecords() async {
    debugPrint('Migrating attendance records to Firebase...');

    // Get all attendance records from Hive
    final records = HiveService.attendanceBox.values.toList();

    for (final record in records) {
      try {
        // Check if record already exists
        final querySnapshot = await FirebaseService.attendanceCollection
            .where('studentId', isEqualTo: record.studentId)
            .where('sessionId', isEqualTo: record.sessionId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('Attendance record for student ${record.studentId} in session ${record.sessionId} already exists, skipping...');
          continue;
        }

        // Create new attendance record in Firebase
        await FirebaseService.attendanceCollection.doc(record.id).set(record.toFirestore());

        debugPrint('Migrated attendance record: ${record.id}');
      } catch (e) {
        debugPrint('Error migrating attendance record ${record.id}: $e');
      }
    }

    debugPrint('✓ Attendance records migration completed');
  }
}
