import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    // Check if Firebase is authenticated
    final firebaseUser = FirebaseService.currentUser;

    if (firebaseUser != null) {
      // Get user data from Firestore
      final user = await FirebaseService.getUserById(firebaseUser.uid);

      // If user exists and is active, return it
      if (user != null && user.status == UserStatus.active) {
        // Also store in Hive for offline access
        await HiveService.userBox.put(user.id, user);
        await HiveService.authBox.put('currentUserId', user.id);
        return user;
      }
    }

    // If no Firebase auth, try Hive for offline mode
    final currentUserId = HiveService.authBox.get('currentUserId');
    if (currentUserId != null) {
      final user = HiveService.userBox.get(currentUserId);
      if (user != null && user.status == UserStatus.active) {
        return user;
      }
    }
    
    return null;
  }

  Future<LoginResult> login(String identifier, String password) async {
    try {
      // Find user by identifier (email or matricule/staff ID)
      final user = await FirebaseService.getUserByIdentifier(identifier);

      if (user == null) {
        return LoginResult.failure('Invalid credentials');
      }

      // Attempt Firebase authentication
      try {
        // Use email for Firebase auth
        await FirebaseService.signInWithEmailAndPassword(user.email, password);
      } catch (e) {
        return LoginResult.failure('Invalid password');
      }

      // Store session in Hive for offline access
      await HiveService.authBox.put('currentUserId', user.id);
      await HiveService.authBox.put('loginTimestamp', DateTime.now().toIso8601String());
      
      // Store user data in Hive
      await HiveService.userBox.put(user.id, user);

      // Update auth state
      state = AsyncValue.data(user);
      return LoginResult.success(user);
    } catch (e) {
      return LoginResult.failure('An error occurred during login: ${e.toString()}');
    }
  }

  // Add password reset method
  Future<bool> requestPasswordReset(String email) async {
    try {
      await FirebaseService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add change password method
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = state.valueOrNull;
      if (user == null) return false;

      // Re-authenticate user with current password to confirm identity
      try {
        await FirebaseService.signInWithEmailAndPassword(user.email, currentPassword);
      } catch (e) {
        return false; // Current password is incorrect
      }

      // Update the password
      await FirebaseService.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseService.signOut();

      // Clear Hive session
      await HiveService.authBox.delete('currentUserId');
      await HiveService.authBox.delete('loginTimestamp');

      // Update state
      state = const AsyncValue.data(null);
    } catch (e) {
      // Handle logout errors
      throw Exception('Error during logout: ${e.toString()}');
    }
  }
}

class LoginResult {
  final bool success;
  final User? user;
  final String? errorMessage;

  LoginResult.success(this.user) : success = true, errorMessage = null;
  LoginResult.failure(this.errorMessage) : success = false, user = null;

  // Add compatibility getter
  bool get isSuccess => success;
}

// Convenience providers
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull;
}

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

@riverpod
UserRole? currentUserRole(CurrentUserRoleRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
}