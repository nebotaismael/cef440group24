import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/hive_service.dart';
import '../services/dummy_data_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async {
    // Initialize dummy data on first run
    await DummyDataService.initializeDummyData();
    
    // Check for existing session
    final authBox = HiveService.authBox;
    final currentUserId = authBox.get('currentUserId');
    
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Find user by matricule/staff ID or email
      User? user;
      for (final u in HiveService.userBox.values) {
        if ((u.matriculeOrStaffId == identifier || u.email == identifier) &&
            u.status == UserStatus.active) {
          user = u;
          break;
        }
      }

      if (user == null) {
        return LoginResult.failure('Invalid credentials');
      }

      // For demo purposes, accept any password that's not empty
      if (password.isEmpty) {
        return LoginResult.failure('Password cannot be empty');
      }

      // Store session
      await HiveService.authBox.put('currentUserId', user.id);
      await HiveService.authBox.put('loginTimestamp', DateTime.now().toIso8601String());
      
      state = AsyncValue.data(user);
      return LoginResult.success(user);
    } catch (e) {
      return LoginResult.failure('An error occurred during login');
    }
  }

  Future<void> logout() async {
    await HiveService.authBox.delete('currentUserId');
    await HiveService.authBox.delete('loginTimestamp');
    state = const AsyncValue.data(null);
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For demo purposes, just validate that passwords are not empty
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        return false;
      }
      
      if (newPassword.length < 6) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if email exists
      final userExists = HiveService.userBox.values.any((user) => user.email == email);
      return userExists;
    } catch (e) {
      return false;
    }
  }
}

class LoginResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;

  LoginResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory LoginResult.success(User user) {
    return LoginResult._(isSuccess: true, user: user);
  }

  factory LoginResult.failure(String message) {
    return LoginResult._(isSuccess: false, errorMessage: message);
  }
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