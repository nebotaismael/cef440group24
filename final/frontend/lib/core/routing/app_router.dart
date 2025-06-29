import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/password_reset_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/student/screens/student_dashboard.dart';
import '../../features/student/screens/facial_enrollment_screen.dart';
import '../../features/student/screens/check_in_screen.dart';
import '../../features/student/screens/attendance_history_screen.dart';
import '../../features/instructor/screens/instructor_dashboard.dart';
import '../../features/instructor/screens/session_management_screen.dart';
import '../../features/instructor/screens/real_time_monitor_screen.dart';
import '../../features/instructor/screens/manual_override_screen.dart';
import '../../features/instructor/screens/instructor_reports_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/course_management_screen.dart';
import '../../features/admin/screens/geofence_management_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/audit_logs_screen.dart';
import '../../features/admin/screens/system_settings_screen.dart';
import '../../features/shared/screens/profile_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.valueOrNull;
      final isAuthenticated = user != null;
      
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnLogin = state.matchedLocation == '/login';
      final isOnPasswordReset = state.matchedLocation.startsWith('/password-reset');
      
      // Show splash while loading
      if (isLoading && !isOnSplash) {
        return '/splash';
      }
      
      // Redirect to login if not authenticated
      if (!isLoading && !isAuthenticated && !isOnLogin && !isOnPasswordReset) {
        return '/login';
      }
      
      // Redirect to appropriate dashboard if authenticated and on auth screens
      if (isAuthenticated && (isOnLogin || isOnSplash || isOnPasswordReset)) {
        return _getHomePath(user.role);
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      
      // Student Routes
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
        routes: [
          GoRoute(
            path: 'facial-enrollment',
            builder: (context, state) => const FacialEnrollmentScreen(),
          ),
          GoRoute(
            path: 'check-in/:sessionId',
            builder: (context, state) => CheckInScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),
          GoRoute(
            path: 'attendance-history',
            builder: (context, state) => const AttendanceHistoryScreen(),
          ),
        ],
      ),
      
      // Instructor Routes
      GoRoute(
        path: '/instructor',
        builder: (context, state) => const InstructorDashboard(),
        routes: [
          GoRoute(
            path: 'session-management/:courseId',
            builder: (context, state) => SessionManagementScreen(
              courseId: state.pathParameters['courseId']!,
            ),
          ),
          GoRoute(
            path: 'monitor/:sessionId',
            builder: (context, state) => RealTimeMonitorScreen(
              sessionId: state.pathParameters['sessionId']!,
            ),
          ),
          GoRoute(
            path: 'override/:sessionId/:studentId',
            builder: (context, state) => ManualOverrideScreen(
              sessionId: state.pathParameters['sessionId']!,
              studentId: state.pathParameters['studentId']!,
            ),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const InstructorReportsScreen(),
          ),
        ],
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
        routes: [
          GoRoute(
            path: 'users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'courses',
            builder: (context, state) => const CourseManagementScreen(),
          ),
          GoRoute(
            path: 'geofences',
            builder: (context, state) => const GeofenceManagementScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: 'audit-logs',
            builder: (context, state) => const AuditLogsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SystemSettingsScreen(),
          ),
        ],
      ),
      
      // Shared Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

String _getHomePath(UserRole role) {
  switch (role) {
    case UserRole.student:
      return '/student';
    case UserRole.instructor:
      return '/instructor';
    case UserRole.admin:
      return '/admin';
  }
}