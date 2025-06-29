import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/auracheck_api_service.dart';
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
      
      final user = ref.read(currentUserProvider);
      if (user == null) return false;

      final File imageFile = File(imagePath);

      // Step 1: Register face with AuraCheck API
      final auraCheckResponse = await AuraCheckApiService.registerFace(imageFile);

      if (!auraCheckResponse.success) {
        // If AuraCheck registration fails, still continue with Firebase for backward compatibility
        print('AuraCheck registration failed: ${auraCheckResponse.error}');
      }

      // Step 2: Continue with existing Firebase storage (preserve existing functionality)
      final bytes = await imageFile.readAsBytes();
      await FirebaseService.storeFacialTemplate(user.id, bytes);

      // Refresh auth state
      ref.invalidate(authProvider);

      return true;
    } catch (e) {
      print('Facial enrollment error: $e');
      return false;
    } finally {
      state = false;
    }
  }

  Future<bool> reEnrollFace(String imagePath) async {
    return enrollFace(imagePath);
  }
}