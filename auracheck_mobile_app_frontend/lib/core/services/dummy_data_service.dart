import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/session.dart';
import '../models/attendance_record.dart';
import '../models/geofence.dart';
import 'hive_service.dart';

class DummyDataService {
 // static const _uuid = Uuid();

  static Future<void> initializeDummyData() async {
    // Check if data already exists
    if (HiveService.userBox.isNotEmpty) return;

    await _createDummyUsers();
    await _createDummyGeofences();
    await _createDummyCourses();
    await _createDummySessions();
    await _createDummyEnrollments();
    await _createDummyAttendanceRecords();
  }

  static Future<void> _createDummyUsers() async {
    final now = DateTime.now();
    
    // Admin users
    final admin = User(
      id: 'admin1',
      fullName: 'System Administrator',
      email: 'admin@ub.edu.cm',
      matriculeOrStaffId: 'ADM001',
      role: UserRole.admin,
      status: UserStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    // Instructor users
    final instructors = [
      User(
        id: 'inst1',
        fullName: 'Dr. Nkemeni Valery',
        email: 'nkemeni.valery@ub.edu.cm',
        matriculeOrStaffId: 'INS001',
        role: UserRole.instructor,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
      User(
        id: 'inst2',
        fullName: 'Prof. John Doe',
        email: 'john.doe@ub.edu.cm',
        matriculeOrStaffId: 'INS002',
        role: UserRole.instructor,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    // Student users
    final students = [
      User(
        id: 'student1',
        fullName: 'Nebota Ismael Owamba',
        email: 'nebota.ismael@ub.edu.cm',
        matriculeOrStaffId: 'FE22A256',
        role: UserRole.student,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
        hasFacialTemplate: true,
      ),
      User(
        id: 'student2',
        fullName: 'Billa Sophia',
        email: 'billa.sophia@ub.edu.cm',
        matriculeOrStaffId: 'FE22A176',
        role: UserRole.student,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
        hasFacialTemplate: true,
      ),
      User(
        id: 'student3',
        fullName: 'Ekane Metuge Akame Favour',
        email: 'ekane.metuge@ub.edu.cm',
        matriculeOrStaffId: 'FE22A199',
        role: UserRole.student,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
        hasFacialTemplate: false,
      ),
      User(
        id: 'student4',
        fullName: 'Eyong Godwill Ngang',
        email: 'eyong.godwill@ub.edu.cm',
        matriculeOrStaffId: 'FE22A214',
        role: UserRole.student,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
        hasFacialTemplate: true,
      ),
      User(
        id: 'student5',
        fullName: 'Onya Martha O',
        email: 'onya.martha@ub.edu.cm',
        matriculeOrStaffId: 'FE22A292',
        role: UserRole.student,
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
        hasFacialTemplate: false,
      ),
    ];

    // Add all users to Hive
    await HiveService.userBox.put('admin1', admin);
    for (final instructor in instructors) {
      await HiveService.userBox.put(instructor.id, instructor);
    }
    for (final student in students) {
      await HiveService.userBox.put(student.id, student);
    }
  }

  static Future<void> _createDummyGeofences() async {
    final now = DateTime.now();
    
    final geofences = [
      Geofence(
        id: 'geo1',
        name: 'FET Amphitheater 101',
        latitude: 4.1644, // University of Buea approximate coordinates
        longitude: 9.2816,
        radius: 50.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Geofence(
        id: 'geo2',
        name: 'Computer Lab A',
        latitude: 4.1648,
        longitude: 9.2820,
        radius: 30.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Geofence(
        id: 'geo3',
        name: 'Lecture Hall B',
        latitude: 4.1640,
        longitude: 9.2812,
        radius: 40.0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final geofence in geofences) {
      await HiveService.geofenceBox.put(geofence.id, geofence);
    }
  }

  static Future<void> _createDummyCourses() async {
    final now = DateTime.now();
    
    final courses = [
      Course(
        id: 'course1',
        courseCode: 'CEF440',
        courseName: 'Internet Programming and Mobile Programming',
        description: 'Advanced course on web and mobile application development',
        instructorId: 'inst1',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course2',
        courseCode: 'CEF420',
        courseName: 'Software Engineering',
        description: 'Principles and practices of software engineering',
        instructorId: 'inst1',
        createdAt: now,
        updatedAt: now,
      ),
      Course(
        id: 'course3',
        courseCode: 'CEF430',
        courseName: 'Database Systems',
        description: 'Design and implementation of database systems',
        instructorId: 'inst2',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final course in courses) {
      await HiveService.courseBox.put(course.id, course);
    }
  }

  static Future<void> _createDummySessions() async {
    final now = DateTime.now();
    
    final sessions = [
      // Active session
      Session(
        id: 'session1',
        courseId: 'course1',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: null,
        geofenceId: 'geo1',
        status: SessionStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
      // Scheduled session
      Session(
        id: 'session2',
        courseId: 'course2',
        startTime: now.add(const Duration(hours: 2)),
        endTime: null,
        geofenceId: 'geo2',
        status: SessionStatus.scheduled,
        createdAt: now,
        updatedAt: now,
      ),
      // Ended session
      Session(
        id: 'session3',
        courseId: 'course1',
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1)),
        geofenceId: 'geo1',
        status: SessionStatus.ended,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Session(
        id: 'session4',
        courseId: 'course3',
        startTime: now.subtract(const Duration(days: 2, hours: 1)),
        endTime: now.subtract(const Duration(days: 2)),
        geofenceId: 'geo3',
        status: SessionStatus.ended,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    for (final session in sessions) {
      await HiveService.sessionBox.put(session.id, session);
    }
  }

  static Future<void> _createDummyEnrollments() async {
    // Enrollment structure: {studentId: [courseIds]}
    final enrollments = {
      'student1': ['course1', 'course2'],
      'student2': ['course1', 'course3'],
      'student3': ['course1', 'course2', 'course3'],
      'student4': ['course2', 'course3'],
      'student5': ['course1'],
    };

    for (final entry in enrollments.entries) {
      await HiveService.enrollmentBox.put(entry.key, entry.value);
    }

    // Also create reverse mapping: {courseId: [studentIds]}
    final courseEnrollments = <String, List<String>>{};
    for (final entry in enrollments.entries) {
      for (final courseId in entry.value) {
        courseEnrollments.putIfAbsent(courseId, () => []).add(entry.key);
      }
    }

    for (final entry in courseEnrollments.entries) {
      await HiveService.enrollmentBox.put('course_${entry.key}', entry.value);
    }
  }

  static Future<void> _createDummyAttendanceRecords() async {
    final now = DateTime.now();
    
    final attendanceRecords = [
      // Session 3 (ended session) - multiple students
      AttendanceRecord(
        id: 'att1',
        studentId: 'student1',
        sessionId: 'session3',
        status: AttendanceStatus.present,
        checkInTimestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 45)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      AttendanceRecord(
        id: 'att2',
        studentId: 'student2',
        sessionId: 'session3',
        status: AttendanceStatus.present,
        checkInTimestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      AttendanceRecord(
        id: 'att3',
        studentId: 'student3',
        sessionId: 'session3',
        status: AttendanceStatus.absent,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      AttendanceRecord(
        id: 'att4',
        studentId: 'student5',
        sessionId: 'session3',
        status: AttendanceStatus.present,
        checkInTimestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 20)),
        overrideJustification: 'Student arrived late due to traffic',
        overrideBy: 'inst1',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      
      // Session 4 (ended session)
      AttendanceRecord(
        id: 'att5',
        studentId: 'student2',
        sessionId: 'session4',
        status: AttendanceStatus.present,
        checkInTimestamp: now.subtract(const Duration(days: 2, minutes: 45)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      AttendanceRecord(
        id: 'att6',
        studentId: 'student3',
        sessionId: 'session4',
        status: AttendanceStatus.present,
        checkInTimestamp: now.subtract(const Duration(days: 2, minutes: 30)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      AttendanceRecord(
        id: 'att7',
        studentId: 'student4',
        sessionId: 'session4',
        status: AttendanceStatus.absent,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    for (final record in attendanceRecords) {
      await HiveService.attendanceBox.put(record.id, record);
    }
  }
}