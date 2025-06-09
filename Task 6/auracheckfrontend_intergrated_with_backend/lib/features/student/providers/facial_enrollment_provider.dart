import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
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
      // 3. Store features in Firebase Storage
      // 4. Update user metadata in Firestore

      final user = ref.read(currentUserProvider);
      if (user != null) {
        // Simulate facial template extraction and storage
        // In a real app, you would process the image to extract features
        // For demo, we'll just use the image file directly
        final File imageFile = File(imagePath);
        final bytes = await imageFile.readAsBytes();

        // Upload facial template to Firebase Storage
        await FirebaseService.storeFacialTemplate(user.id, bytes);

        // Refresh auth state
        ref.invalidate(authProvider);

        return true;
      }

      return false;
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