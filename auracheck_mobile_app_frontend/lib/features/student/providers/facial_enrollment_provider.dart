import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/providers/auth_provider.dart';

part 'facial_enrollment_provider.g.dart';

@riverpod
class FacialEnrollment extends _$FacialEnrollment {
  @override
  bool build() {
    return false;
  }

  Future<bool> enrollFace(String imagePath) async {
    try {
      state = true;
      
      // Simulate facial feature extraction processing
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real implementation, this would:
      // 1. Process the image using ML Kit or similar
      // 2. Extract facial features
      // 3. Send to backend for secure storage
      // 4. Handle response
      
      // For demo purposes, we'll simulate success and update user
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final updatedUser = user.copyWith(
          hasFacialTemplate: true,
          updatedAt: DateTime.now(),
        );
        
        await HiveService.userBox.put(user.id, updatedUser);
        
        // Refresh auth state
        ref.invalidate(authProvider);
      }
      
      return true;
    } catch (e) {
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> reEnrollFace(String imagePath) async {
    return enrollFace(imagePath);
  }
}