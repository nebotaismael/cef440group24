import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/course.dart';
import '../models/session.dart';
import '../models/attendance_record.dart';
import '../models/geofence.dart';

class HiveService {
  static const String userBoxName = 'users';
  static const String courseBoxName = 'courses';
  static const String sessionBoxName = 'sessions';
  static const String attendanceBoxName = 'attendance_records';
  static const String geofenceBoxName = 'geofences';
  static const String enrollmentBoxName = 'enrollments';
  static const String authBoxName = 'auth';

  static Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(UserRoleAdapter());
    Hive.registerAdapter(UserStatusAdapter());
    Hive.registerAdapter(CourseAdapter());
    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(SessionStatusAdapter());
    Hive.registerAdapter(AttendanceRecordAdapter());
    Hive.registerAdapter(AttendanceStatusAdapter());
    Hive.registerAdapter(GeofenceAdapter());

    // Open boxes
    await Hive.openBox<User>(userBoxName);
    await Hive.openBox<Course>(courseBoxName);
    await Hive.openBox<Session>(sessionBoxName);
    await Hive.openBox<AttendanceRecord>(attendanceBoxName);
    await Hive.openBox<Geofence>(geofenceBoxName);
    await Hive.openBox(enrollmentBoxName);
    await Hive.openBox(authBoxName);
  }

  static Box<User> get userBox => Hive.box<User>(userBoxName);
  static Box<Course> get courseBox => Hive.box<Course>(courseBoxName);
  static Box<Session> get sessionBox => Hive.box<Session>(sessionBoxName);
  static Box<AttendanceRecord> get attendanceBox => Hive.box<AttendanceRecord>(attendanceBoxName);
  static Box<Geofence> get geofenceBox => Hive.box<Geofence>(geofenceBoxName);
  static Box get enrollmentBox => Hive.box(enrollmentBoxName);
  static Box get authBox => Hive.box(authBoxName);

  static Future<void> clearAllData() async {
    await userBox.clear();
    await courseBox.clear();
    await sessionBox.clear();
    await attendanceBox.clear();
    await geofenceBox.clear();
    await enrollmentBox.clear();
    await authBox.clear();
  }
}