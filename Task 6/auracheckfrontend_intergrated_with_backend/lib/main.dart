import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app.dart';
import 'core/services/hive_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/firebase_migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initializeFirebase();

  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();
  
  // Migrate data to Firebase (only runs once)
  try {
    await FirebaseMigrationService.migrateDataToFirebase();
    debugPrint('Firebase migration complete');
  } catch (e) {
    debugPrint('Error during Firebase migration: $e');
    // Continue app initialization even if migration fails
  }

  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const AuraCheckApp();
        },
      ),
    ),
  );
}