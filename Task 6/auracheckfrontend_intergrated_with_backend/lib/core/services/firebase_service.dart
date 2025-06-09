import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart' as app_user;
import '../models/course.dart';
import '../models/session.dart';
import '../models/geofence.dart';
import '../models/attendance_record.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Firebase instances
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firebase collections
  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  static CollectionReference<Map<String, dynamic>> get coursesCollection =>
      _firestore.collection('courses');

  static CollectionReference<Map<String, dynamic>> get sessionsCollection =>
      _firestore.collection('sessions');

  static CollectionReference<Map<String, dynamic>> get attendanceCollection =>
      _firestore.collection('attendance');

  static CollectionReference<Map<String, dynamic>> get geofencesCollection =>
      _firestore.collection('geofences');

  static CollectionReference<Map<String, dynamic>> get enrollmentsCollection =>
      _firestore.collection('enrollments');

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  //  await _auth.setPersistence(auth.Persistence.LOCAL);
  }

  // Authentication Methods
  static Future<auth.UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static auth.User? get currentUser => _auth.currentUser;

  static bool get isSignedIn => _auth.currentUser != null;

  // Add missing methods for password management
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }
    await user.updatePassword(newPassword);
  }

  // User Management
  static Future<String> createUser(app_user.User user) async {
    // Check if user exists
    final emailQuery = await usersCollection.where('email', isEqualTo: user.email).get();
    if (emailQuery.docs.isNotEmpty) {
      throw Exception('User with this email already exists');
    }

    final idQuery = await usersCollection.where('matriculeOrStaffId', isEqualTo: user.matriculeOrStaffId).get();
    if (idQuery.docs.isNotEmpty) {
      throw Exception('User with this ID already exists');
    }

    // Create auth user
    auth.UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.matriculeOrStaffId, // Initial password
    );

    // Add to Firestore
    final userDoc = usersCollection.doc(credential.user!.uid);
    await userDoc.set(user.toFirestore());

    return userDoc.id;
  }

  static Future<app_user.User?> getUserById(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return app_user.User.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
    }
    return null;
  }

  static Future<app_user.User?> getUserByIdentifier(String identifier) async {
    // Check email
    var snapshot = await usersCollection
        .where('email', isEqualTo: identifier)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return app_user.User.fromFirestore(snapshot.docs.first);
    }

    // Check matricule/staff ID
    snapshot = await usersCollection
        .where('matriculeOrStaffId', isEqualTo: identifier)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return app_user.User.fromFirestore(snapshot.docs.first);
    }

    return null;
  }

  static Future<List<app_user.User>> getAllUsers() async {
    final snapshot = await usersCollection.get();
    return snapshot.docs.map((doc) => app_user.User.fromFirestore(doc)).toList();
  }

  static Future<List<app_user.User>> getUsersByRole(app_user.UserRole role) async {
    final snapshot = await usersCollection
        .where('role', isEqualTo: role.toString())
        .get();

    return snapshot.docs.map((doc) => app_user.User.fromFirestore(doc)).toList();
  }

  static Future<void> updateUser(app_user.User user) async {
    await usersCollection.doc(user.id).update(user.toFirestore());
  }

  // Facial Templates
  static Future<String> storeFacialTemplate(String userId, Uint8List templateData) async {
    final storageRef = _storage.ref().child('facial_templates/$userId.dat');
    await storageRef.putData(templateData);

    await usersCollection.doc(userId).update({
      'hasFacialTemplate': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return await storageRef.getDownloadURL();
  }

  static Future<Uint8List?> getFacialTemplate(String userId) async {
    try {
      final storageRef = _storage.ref().child('facial_templates/$userId.dat');
      return await storageRef.getData();
    } catch (e) {
      debugPrint('Error getting facial template: $e');
      return null;
    }
  }

  // Course Management
  static Future<String> createCourse(Course course) async {
    final docRef = await coursesCollection.add(course.toFirestore());
    return docRef.id;
  }

  static Future<Course?> getCourseById(String courseId) async {
    try {
      final doc = await coursesCollection.doc(courseId).get();
      if (doc.exists) {
        return Course.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting course: $e');
    }
    return null;
  }

  static Future<List<Course>> getAllCourses() async {
    final snapshot = await coursesCollection.get();
    return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
  }

  static Future<List<Course>> getCoursesByInstructor(String instructorId) async {
    final snapshot = await coursesCollection
        .where('instructorId', isEqualTo: instructorId)
        .get();

    return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
  }

  static Future<void> addCourse(Course course) async {
    await coursesCollection.doc(course.id).set(course.toFirestore());
  }

  static Future<void> updateCourse(Course course) async {
    await coursesCollection.doc(course.id).update(course.toFirestore());
  }

  static Future<void> deleteCourse(String courseId) async {
    // Delete course
    await coursesCollection.doc(courseId).delete();

    // Delete associated sessions
    final sessionsSnapshot = await sessionsCollection
        .where('courseId', isEqualTo: courseId)
        .get();

    final batch = _firestore.batch();
    for (final doc in sessionsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Enrollment Management
  static Future<void> enrollStudent(String studentId, String courseId) async {
    final existingQuery = await enrollmentsCollection
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .get();

    if (existingQuery.docs.isNotEmpty) return; // Already enrolled

    await enrollmentsCollection.add({
      'studentId': studentId,
      'courseId': courseId,
      'enrolledAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unenrollStudent(String studentId, String courseId) async {
    final enrollmentQuery = await enrollmentsCollection
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .get();

    for (final doc in enrollmentQuery.docs) {
      await doc.reference.delete();
    }
  }

  static Future<List<String>> getEnrolledStudentIds(String courseId) async {
    final snapshot = await enrollmentsCollection
        .where('courseId', isEqualTo: courseId)
        .get();

    return snapshot.docs.map((doc) => doc.data()['studentId'] as String).toList();
  }

  static Future<List<String>> getStudentCourseIds(String studentId) async {
    final snapshot = await enrollmentsCollection
        .where('studentId', isEqualTo: studentId)
        .get();

    return snapshot.docs.map((doc) => doc.data()['courseId'] as String).toList();
  }

  // Session Management
  static Future<String> createSession(Session session) async {
    final docRef = await sessionsCollection.add(session.toFirestore());
    return docRef.id;
  }

  static Future<Session?> getSessionById(String sessionId) async {
    try {
      final doc = await sessionsCollection.doc(sessionId).get();
      if (doc.exists) {
        return Session.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting session: $e');
    }
    return null;
  }

  static Future<void> updateSession(Session session) async {
    await sessionsCollection.doc(session.id).update(session.toFirestore());
  }

  static Future<List<Session>> getSessionsByCourse(String courseId) async {
    final snapshot = await sessionsCollection
        .where('courseId', isEqualTo: courseId)
        .orderBy('startTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
  }

  static Future<List<Session>> getActiveSessions() async {
    final snapshot = await sessionsCollection
        .where('status', isEqualTo: SessionStatus.active.toString())
        .get();

    return snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList();
  }

  // Attendance Management
  static Future<String> createAttendanceRecord(AttendanceRecord record) async {
    final docRef = await attendanceCollection.add(record.toFirestore());
    return docRef.id;
  }

  static Future<void> updateAttendanceRecord(AttendanceRecord record) async {
    await attendanceCollection.doc(record.id).update(record.toFirestore());
  }

  static Future<List<AttendanceRecord>> getAttendanceRecordsBySession(String sessionId) async {
    final snapshot = await attendanceCollection
        .where('sessionId', isEqualTo: sessionId)
        .get();

    return snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();
  }

  static Future<List<AttendanceRecord>> getAttendanceRecordsByStudent(String studentId) async {
    final snapshot = await attendanceCollection
        .where('studentId', isEqualTo: studentId)
        .get();

    return snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();
  }

  static Future<AttendanceRecord?> getStudentAttendanceForSession(
      String studentId, String sessionId) async {
    final snapshot = await attendanceCollection
        .where('studentId', isEqualTo: studentId)
        .where('sessionId', isEqualTo: sessionId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AttendanceRecord.fromFirestore(snapshot.docs.first);
    }

    return null;
  }

  // Geofence Management
  static Future<String> createGeofence(Geofence geofence) async {
    final docRef = await geofencesCollection.add(geofence.toFirestore());
    return docRef.id;
  }

  static Future<Geofence?> getGeofenceById(String geofenceId) async {
    try {
      final doc = await geofencesCollection.doc(geofenceId).get();
      if (doc.exists) {
        return Geofence.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting geofence: $e');
    }
    return null;
  }

  static Future<void> updateGeofence(Geofence geofence) async {
    await geofencesCollection.doc(geofence.id).update(geofence.toFirestore());
  }

  static Future<List<Geofence>> getAllGeofences() async {
    final snapshot = await geofencesCollection.get();
    return snapshot.docs.map((doc) => Geofence.fromFirestore(doc)).toList();
  }

  static Future<List<Geofence>> getActiveGeofences() async {
    final snapshot = await geofencesCollection
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Geofence.fromFirestore(doc)).toList();
  }

  // Utility methods
  static WriteBatch batch() => _firestore.batch();

  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler
  ) {
    return _firestore.runTransaction(transactionHandler);
  }
}
