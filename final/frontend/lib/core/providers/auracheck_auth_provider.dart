import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auracheck_api_service.dart';
import '../models/user.dart';
import 'auth_provider.dart';

// Provider for AuraCheck authentication status
final auraCheckAuthProvider = StateNotifierProvider<AuraCheckAuthNotifier, AuraCheckAuthState>((ref) {
  return AuraCheckAuthNotifier(ref);
});

class AuraCheckAuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? auraCheckUser;
  final String? error;

  AuraCheckAuthState({
    this.isAuthenticated = false,
    this.auraCheckUser,
    this.error,
  });

  AuraCheckAuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? auraCheckUser,
    String? error,
  }) {
    return AuraCheckAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      auraCheckUser: auraCheckUser ?? this.auraCheckUser,
      error: error,
    );
  }
}

class AuraCheckAuthNotifier extends StateNotifier<AuraCheckAuthState> {
  final Ref ref;

  AuraCheckAuthNotifier(this.ref) : super(AuraCheckAuthState()) {
    _checkStoredAuth();
  }

  Future<void> _checkStoredAuth() async {
    try {
      final token = await AuraCheckApiService.getToken();
      final user = await AuraCheckApiService.getStoredUser();

      if (token != null && user != null) {
        // Verify token is still valid with health check
        final healthResponse = await AuraCheckApiService.healthCheck();
        if (healthResponse.success) {
          state = state.copyWith(
            isAuthenticated: true,
            auraCheckUser: user,
            error: null,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to verify stored authentication');
    }
  }

  Future<bool> loginWithCurrentUser() async {
    try {
      // Get current user from your existing auth provider
      final currentUserAsync = ref.read(authProvider);
      final currentUser = currentUserAsync.value;

      if (currentUser == null) {
        state = state.copyWith(error: 'No current user found');
        return false;
      }

      // Use your existing User model properties
      final email = currentUser.email;
      final matricule = currentUser.matriculeOrStaffId;

      if (email.isEmpty || matricule.isEmpty) {
        state = state.copyWith(error: 'User email or matricule/staff ID not available');
        return false;
      }

      final response = await AuraCheckApiService.login(email, matricule);

      if (response.success) {
        state = state.copyWith(
          isAuthenticated: true,
          auraCheckUser: response.data!.user,
          error: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          error: response.error,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        error: 'Login failed: $e',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await AuraCheckApiService.clearCredentials();
    state = AuraCheckAuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
