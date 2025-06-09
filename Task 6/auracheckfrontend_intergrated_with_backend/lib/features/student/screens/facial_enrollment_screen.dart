import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../providers/facial_enrollment_provider.dart';

class FacialEnrollmentScreen extends ConsumerStatefulWidget {
  const FacialEnrollmentScreen({super.key});

  @override
  ConsumerState<FacialEnrollmentScreen> createState() => _FacialEnrollmentScreenState();
}

class _FacialEnrollmentScreenState extends ConsumerState<FacialEnrollmentScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _feedbackMessage = 'Position your face within the frame';
  int _currentStep = 0;

  final List<String> _steps = [
    'Privacy Consent',
    'Camera Setup',
    'Face Capture',
    'Processing',
    'Complete'
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final permission = await Permission.camera.request();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _currentStep = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera access is required for facial enrollment. Please grant permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _currentStep = 3;
      _feedbackMessage = 'Processing facial features...';
    });

    try {
      final image = await _cameraController!.takePicture();
      
      // Simulate facial feature extraction and processing
      await Future.delayed(const Duration(seconds: 2));
      
      final success = await ref.read(facialEnrollmentProvider.notifier).enrollFace(image.path);
      
      if (success) {
        setState(() {
          _currentStep = 4;
          _feedbackMessage = 'Enrollment successful!';
        });
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Facial enrollment completed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      } else {
        setState(() {
          _feedbackMessage = 'Enrollment failed. Please try again.';
          _currentStep = 2;
        });
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Error: $e';
        _currentStep = 2;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isProcessing,
      message: _feedbackMessage,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Facial Enrollment',
          showLogout: false,
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            
            Expanded(
              child: _currentStep == 0 
                  ? _buildConsentStep()
                  : _currentStep < 3
                      ? _buildCameraStep()
                      : _buildCompleteStep(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            'Step ${_currentStep + 1} of ${_steps.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 8.h),
          Text(
            _steps[_currentStep],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentStep() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Icon(
            Icons.privacy_tip,
            size: 80.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 24.h),
          Text(
            'Privacy Notice',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                '''
We need to capture your facial features to enable secure attendance verification.

• Your facial data will be processed on your device
• Only mathematical features (not images) are stored
• Data is encrypted and secure
• Used only for attendance verification
• You can re-enroll or delete anytime

By proceeding, you consent to this facial data collection and processing for attendance management purposes.
                ''',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Decline',
                  onPressed: () => context.pop(),
                  backgroundColor: AppColors.grey400,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomButton(
                  text: 'Accept & Continue',
                  onPressed: () {
                    setState(() => _currentStep = 1);
                    _initializeCamera();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Camera Preview
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.grey300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: _isCameraInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          CameraPreview(_cameraController!),
                          
                          // Face outline guide
                          Container(
                            width: 200.w,
                            height: 250.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(120.r),
                            ),
                          ),
                          
                          // Instructions overlay
                          Positioned(
                            bottom: 20.h,
                            left: 20.w,
                            right: 20.w,
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                _feedbackMessage,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Instructions
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  'Instructions:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                const Text('• Position your face within the oval guide'),
                const Text('• Ensure good lighting'),
                const Text('• Look directly at the camera'),
                const Text('• Remove glasses or masks if possible'),
                const Text('• Keep a neutral expression'),
              ],
            ),
          ),
          
          SizedBox(height: 24.h),
          
          // Capture Button
          if (_isCameraInitialized)
            CustomButton(
              text: 'Capture Face',
              onPressed: _isProcessing ? null : _captureAndProcess,
              icon: const Icon(Icons.camera_alt),
            ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 100.sp,
            color: AppColors.success,
          ),
          SizedBox(height: 24.h),
          Text(
            'Enrollment Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your facial features have been successfully enrolled. You can now use face recognition for attendance check-in.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'Continue to Dashboard',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}