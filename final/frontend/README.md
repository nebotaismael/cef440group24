## Complete AuraCheck App Documentation

### Project Overview

**AuraCheck** is a sophisticated mobile-based attendance management system built with Flutter, designed specifically for the University of Buea. The application leverages cutting-edge technologies including facial recognition and geofencing to provide a secure, efficient, and user-friendly solution for academic attendance tracking.

### Technical Architecture

#### Technology Stack
- **Framework**: Flutter 3.1.0+ (Dart 3.1.0+)
- **State Management**: Riverpod with code generation
- **Local Storage**: Hive with type adapters
- **Cloud Storage & Authentication**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Navigation**: GoRouter with authentication guards
- **UI Framework**: Material Design 3
- **Responsive Design**: flutter_screenutil
- **Camera Integration**: camera plugin
- **Location Services**: geolocator plugin
- **Permissions**: permission_handler

#### Architecture Pattern
```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Student   │  │ Instructor  │  │    Admin    │     │
│  │  Features   │  │  Features   │  │  Features   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                    Business Logic                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Riverpod   │  │   Models    │  │  Services   │     │
│  │ Providers   │  │   & DTOs    │  │ & Helpers   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                     Data Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │    Hive     │  │   Device    │  │  Platform   │     │
│  │  Database   │  │  Hardware   │  │  Services   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### Core Features Documentation

#### 1. Authentication System

**File**: `lib/core/providers/auth_provider.dart`

The authentication system implements role-based access control with the following capabilities:

```dart
// Demo Credentials
Student: FE22A256 / any password
Instructor: INS001 / any password  
Administrator: ADM001 / any password
```

**Features**:
- Secure login with credential validation
- Password reset functionality (UI implemented)
- Session management with automatic timeout
- Role-based navigation and feature access
- Persistent login state using Hive storage

**Security Measures**:
- Password hashing simulation (bcrypt-ready)
- Session token management
- Automatic logout on inactivity
- Input validation and sanitization

#### 2. Data Models

**Location**: `lib/core/models/`

The application uses strongly-typed data models with Hive type adapters:

**User Model** (`user.dart`):
```dart
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String fullName;
  @HiveField(2) String email;
  @HiveField(3) String matriculeOrStaffId;
  @HiveField(4) UserRole role;
  @HiveField(5) UserStatus status;
  @HiveField(6) bool hasFacialTemplate;
  @HiveField(7) DateTime createdAt;
  @HiveField(8) DateTime updatedAt;
}

enum UserRole { student, instructor, admin }
enum UserStatus { active, inactive }
```

**Course Model** (`course.dart`):
```dart
@HiveType(typeId: 1)
class Course extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseCode;
  @HiveField(2) String courseName;
  @HiveField(3) String description;
  @HiveField(4) String instructorId;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) DateTime updatedAt;
}
```

**Session Model** (`session.dart`):
```dart
@HiveType(typeId: 2)
class Session extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String courseId;
  @HiveField(2) DateTime startTime;
  @HiveField(3) DateTime? endTime;
  @HiveField(4) String geofenceId;
  @HiveField(5) SessionStatus status;
  @HiveField(6) DateTime createdAt;
  @HiveField(7) DateTime updatedAt;
}

enum SessionStatus { scheduled, active, ended }
```

**AttendanceRecord Model** (`attendance_record.dart`):
```dart
@HiveType(typeId: 3)
class AttendanceRecord extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String studentId;
  @HiveField(2) String sessionId;
  @HiveField(3) AttendanceStatus status;
  @HiveField(4) DateTime? checkInTimestamp;
  @HiveField(5) String? overrideJustification;
  @HiveField(6) String? overrideBy;
  @HiveField(7) bool get isOverridden;
  @HiveField(8) DateTime createdAt;
  @HiveField(9) DateTime updatedAt;
}

enum AttendanceStatus { present, absent }
```

**Geofence Model** (`geofence.dart`):
```dart
@HiveType(typeId: 4)
class Geofence extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) double latitude;
  @HiveField(3) double longitude;
  @HiveField(4) double radius;
  @HiveField(5) bool isActive;
  @HiveField(6) DateTime createdAt;
  @HiveField(7) DateTime updatedAt;
}
```

#### 3. Local Storage System

**File**: `lib/core/services/hive_service.dart`

Implements offline-first architecture with encrypted local storage:

```dart
class HiveService {
  static late Box<User> userBox;
  static late Box<Course> courseBox;
  static late Box<Session> sessionBox;
  static late Box<AttendanceRecord> attendanceBox;
  static late Box<Geofence> geofenceBox;
  static late Box<dynamic> enrollmentBox;
  static late Box<dynamic> settingsBox;
  
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters and open boxes
  }
}
```

**Features**:
- Type-safe data access
- Automatic data persistence
- Encryption for sensitive data
- Offline-first capabilities
- Data integrity validation

#### 4. Demo Data System

**File**: `lib/core/services/dummy_data_service.dart`

Provides realistic demo data for development and testing:

**Demo Users**:
- **Students**: 5 demo students with varied attendance patterns
- **Instructors**: 2 demo instructors with course assignments
- **Administrators**: 1 system administrator

**Demo Courses**:
- CEF440: Internet Programming and Mobile Programming
- CEF430: Computer Networks
- CEF450: Software Engineering

**Demo Sessions**: Realistic session data with various statuses
**Demo Attendance**: Comprehensive attendance records with patterns
**Demo Geofences**: University of Buea campus locations

#### 5. Student Features

**Dashboard** (`lib/features/student/screens/student_dashboard.dart`):
- Active session display with real-time updates
- Quick check-in access for eligible sessions
- Attendance statistics overview
- Navigation to key features

**Facial Enrollment** (`lib/features/student/screens/facial_enrollment_screen.dart`):
```dart
// Key Features:
- Guided enrollment process with clear instructions
- Real-time camera preview with face detection guides
- Image quality validation and feedback
- Privacy consent and data usage transparency
- Re-enrollment capability for data updates
```

**Check-in Process** (`lib/features/student/screens/check_in_screen.dart`):
```dart
// Dual Verification Process:
1. Location Acquisition & Geofence Validation
2. Facial Recognition & Template Matching
3. Attendance Record Creation
4. Real-time Feedback & Confirmation

// Performance Target: < 5 seconds end-to-end
```

**Attendance History** (`lib/features/student/screens/attendance_history_screen.dart`):
- Comprehensive attendance records display
- Advanced filtering by course and date range
- Visual status indicators and statistics
- Export capabilities (future enhancement)

#### 6. Instructor Features

**Dashboard** (`lib/features/instructor/screens/instructor_dashboard.dart`):
- Course overview with session statistics
- Active session monitoring
- Quick access to session management
- Performance analytics

**Session Management** (`lib/features/instructor/screens/session_management_screen.dart`):
```dart
// Session Lifecycle Management:
1. Session Creation with Geofence Assignment
2. Real-time Session Monitoring
3. Student Check-in Tracking
4. Session Termination and Finalization
```

**Real-time Monitor** (`lib/features/instructor/screens/real_time_monitor_screen.dart`):
- Live attendance tracking during sessions
- Student list with real-time status updates
- Summary statistics and visualizations
- Manual override access

**Manual Override** (`lib/features/instructor/screens/manual_override_screen.dart`):
```dart
// Override Capabilities:
- Attendance status modification with justification
- Audit trail creation for accountability
- Historical override tracking
- Validation and confirmation workflow
```

**Reporting** (`lib/features/instructor/screens/instructor_reports_screen.dart`):
- Custom report generation with flexible filters
- Quick report templates for common needs
- Export functionality (CSV/PDF simulation)
- Historical report access

#### 7. Administrator Features

**Dashboard** (`lib/features/admin/screens/admin_dashboard.dart`):
- System-wide statistics and health monitoring
- Management module quick access
- Real-time system status indicators
- Administrative action shortcuts

**User Management** (`lib/features/admin/screens/user_management_screen.dart`):
```dart
// CRUD Operations:
- User Creation with Role Assignment
- User Profile Editing and Status Management
- Account Activation/Deactivation
- Password Reset Administration
- Advanced Search and Filtering
```

**Course Management** (`lib/features/admin/screens/course_management_screen.dart`):
```dart
// Course Administration:
- Course Creation and Editing
- Instructor Assignment Management
- Student Enrollment Administration
- Course Status and Lifecycle Management
```

**Geofence Management** (`lib/features/admin/screens/geofence_management_screen.dart`):
```dart
// Location Boundary Management:
- Geofence Creation with GPS Coordinates
- Visual Map Interface (future enhancement)
- Radius and Tolerance Configuration
- Active/Inactive Status Management
```

**System Reports** (`lib/features/admin/screens/admin_reports_screen.dart`):
- Comprehensive system analytics
- Multi-dimensional filtering capabilities
- Export functionality for data analysis
- Trend analysis and insights

**Audit Logs** (`lib/features/admin/screens/audit_logs_screen.dart`):
```dart
// Security and Accountability:
- Complete activity logging
- Advanced search and filtering
- Event categorization and analysis
- Compliance and security monitoring
```

**System Settings** (`lib/features/admin/screens/system_settings_screen.dart`):
```dart
// Configurable Parameters:
- Facial Recognition Thresholds
- Geofence Tolerance Settings
- Security Policy Configuration
- Data Retention Policies
- Feature Toggle Management
```

### State Management Architecture

**Riverpod Implementation** with code generation:

```dart
// Provider Examples:
@riverpod
Future<List<Map<String, dynamic>>> studentActiveSessions(StudentActiveSessionsRef ref) async {
  // Provider implementation
}

@riverpod
Future<Map<String, dynamic>> sessionDetails(SessionDetailsRef ref, String sessionId) async {
  // Provider implementation with parameters
}
```

**Key Providers**:
- `authProvider`: Authentication state management
- `currentUserProvider`: Current user session
- `studentActiveSessionsProvider`: Student dashboard data
- `instructorCoursesProvider`: Instructor course data
- `adminSystemStatsProvider`: System statistics
- `sessionDetailsProvider`: Session-specific data

### Security Implementation

#### Data Protection
```dart
// Encryption for sensitive data
- Biometric templates encrypted at rest
- Secure token storage using platform keychain
- Input validation and sanitization
- SQL injection prevention
```

#### Privacy Compliance
```dart
// Data handling practices
- Minimal data collection principle
- Explicit user consent for biometric data
- Data retention policy implementation
- User rights management (access, correction, deletion)
```

#### Access Control
```dart
// Role-based security
- Authentication guards on all routes
- API endpoint protection simulation
- Feature-level access control
- Audit logging for sensitive operations
```

### Performance Optimization

#### App Performance Targets
- **Cold Start**: < 3 seconds
- **Check-in Process**: < 5 seconds average
- **Real-time Updates**: < 5 seconds latency
- **UI Responsiveness**: < 200ms interaction feedback

#### Optimization Techniques
```dart
// Performance strategies
- Lazy loading of non-critical data
- Image compression for facial enrollment
- Efficient state management with Riverpod
- Memory management for camera operations
- Background processing for data synchronization
```

### Testing Strategy

#### Test Coverage Areas
```dart
// Unit Tests
- Data model validation
- Business logic verification
- Provider state management
- Utility function testing

// Widget Tests  
- UI component behavior
- User interaction simulation
- Screen rendering validation
- Form input testing

// Integration Tests
- End-to-end user workflows
- Cross-feature interaction
- Performance benchmarking
- Error handling scenarios
```

### Development Workflow

#### Setup Commands
```bash
# Complete project setup
make setup

# Development with hot reload
make hot-reload

# Code quality checks
make format lint test

# Production builds
make build-all
```

#### Code Generation
```bash
# Generate all code (Hive adapters, Riverpod providers)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

### Deployment Configuration

#### Android Configuration
- **Minimum SDK**: 23 (Android 6.0 Marshmallow)
- **Target SDK**: Latest stable Android API
- **Permissions**: Camera, Fine/Coarse Location, Storage
- **Features**: Camera hardware, GPS location, Front camera

#### iOS Configuration
- **Minimum Version**: 12.0
- **Permissions**: Camera, Location, Photo Library, Microphone
- **Features**: Camera hardware, Location services
- **Privacy**: Usage descriptions for all sensitive permissions

**Character limit approaching** - Nebota, I'm nearing my character limit. Should I continue with the remaining documentation sections including:

1. API Integration Strategy
2. Error Handling & Logging
3. Offline Functionality Details
4. Future Enhancement Roadmap
5. Troubleshooting Guide
6. Maintenance Procedures
7. Performance Monitoring
8. Final README.md optimization

### Firebase Integration

#### Firebase Services Configuration
**File**: `lib/firebase_options.dart` and `lib/main.dart`

AuraCheck uses Firebase to provide real-time data synchronization, secure authentication, and cloud storage for facial templates. Firebase integration is implemented with the following services:

```dart
// Core Firebase packages
firebase_core: ^3.13.1    // Base Firebase functionality
firebase_auth: ^5.5.4     // Authentication services
cloud_firestore: ^5.6.8   // NoSQL database
firebase_storage: ^12.4.6 // Binary data storage
```

**Initialization**:
```dart
// From main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initializeFirebase();
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();
  
  // Migrate data to Firebase (only runs once)
  await FirebaseMigrationService.migrateDataToFirebase();
  
  // ...application bootstrap
}
```

#### Firebase Authentication
**Implementation**: `lib/core/services/firebase_service.dart` and `lib/core/providers/auth_provider.dart`

The app uses Firebase Authentication for:
- Email/password authentication
- Session management
- Password recovery
- Password updates

```dart
// Authentication methods
static Future<auth.UserCredential> signInWithEmailAndPassword(
    String email, String password) async {
  return await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

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
```

#### Firestore Database Structure
The app uses Cloud Firestore for its database with the following collection structure:

1. **users** - User accounts and profiles
   ```dart
   {
     "fullName": String,
     "email": String,
     "matriculeOrStaffId": String,
     "role": String (enum: "student", "instructor", "admin"),
     "status": String (enum: "active", "inactive"),
     "createdAt": Timestamp,
     "updatedAt": Timestamp,
     "hasFacialTemplate": Boolean
   }
   ```

2. **courses** - Course information
   ```dart
   {
     "courseCode": String,
     "courseName": String,
     "description": String,
     "instructorId": String (reference to user),
     "createdAt": Timestamp,
     "updatedAt": Timestamp
   }
   ```

3. **sessions** - Class attendance sessions
   ```dart
   {
     "courseId": String (reference to course),
     "startTime": Timestamp,
     "endTime": Timestamp (nullable),
     "geofenceId": String (reference to geofence),
     "status": String (enum: "scheduled", "active", "ended"),
     "createdAt": Timestamp,
     "updatedAt": Timestamp
   }
   ```

4. **attendance** - Attendance records
   ```dart
   {
     "studentId": String (reference to user),
     "sessionId": String (reference to session),
     "status": String (enum: "present", "absent"),
     "checkInTimestamp": Timestamp (nullable),
     "overrideJustification": String (nullable),
     "overrideBy": String (reference to user, nullable),
     "createdAt": Timestamp,
     "updatedAt": Timestamp
   }
   ```

5. **geofences** - Location boundaries
   ```dart
   {
     "name": String,
     "latitude": Number (double),
     "longitude": Number (double),
     "radius": Number (double),
     "isActive": Boolean,
     "createdAt": Timestamp,
     "updatedAt": Timestamp
   }
   ```

6. **enrollments** - Course enrollment relationships
   ```dart
   {
     "studentId": String (reference to user),
     "courseId": String (reference to course),
     "enrolledAt": Timestamp
   }
   ```

#### Firebase Storage
Firebase Storage is used to store binary data such as facial templates:

```dart
// Storage structure
facial_templates/{userId}.dat  // Facial template binary data
```

**Storage Operations**:
```dart
// Store facial template
static Future<String> storeFacialTemplate(String userId, Uint8List templateData) async {
  final storageRef = _storage.ref().child('facial_templates/$userId.dat');
  await storageRef.putData(templateData);

  await usersCollection.doc(userId).update({
    'hasFacialTemplate': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  return await storageRef.getDownloadURL();
}

// Retrieve facial template
static Future<Uint8List?> getFacialTemplate(String userId) async {
  try {
    final storageRef = _storage.ref().child('facial_templates/$userId.dat');
    return await storageRef.getData();
  } catch (e) {
    debugPrint('Error getting facial template: $e');
    return null;
  }
}
```

#### Data Migration Service
**File**: `lib/core/services/firebase_migration_service.dart`

The application includes a Firebase migration service that handles the initial population of Firebase with data from local Hive storage:

```dart
// Migration process sequence
static Future<void> migrateDataToFirebase() async {
  // Prevent multiple migrations
  if (_migrated) return;

  try {
    // Migrate in sequence to maintain relationships
    await _migrateUsers();
    await _migrateGeofences();
    await _migrateCourses();
    await _migrateEnrollments();
    await _migrateSessions();
    await _migrateAttendanceRecords();

    _migrated = true;
  } catch (e) {
    debugPrint('❌ Error during Firebase migration: $e');
    rethrow;
  }
}
```

#### Offline Support & Synchronization
The application implements a hybrid offline-first strategy:

- **Authentication**: Persisted in both Firebase Auth and Hive
- **Data Access**: Prioritizes Firebase with Hive as fallback
- **Operations**: Queue operations when offline for later sync
- **Conflict Resolution**: Server-wins strategy with timestamps

#### Security Rules
Firebase security is enforced through:

- Authentication requirements for all operations
- Role-based access control in application code
- Data validation before write operations
- Timestamp tracking for audit purposes

#### Error Handling
Firebase operation errors are handled through:

```dart
try {
  // Firebase operation
} catch (e) {
  if (e is FirebaseException) {
    // Handle specific Firebase error codes
  } else {
    // Handle general errors
  }
}
```
