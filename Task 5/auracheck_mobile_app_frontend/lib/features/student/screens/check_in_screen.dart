import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../providers/check_in_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const CheckInScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _statusMessage = 'Initializing...';
  CheckInStep _currentStep = CheckInStep.initializing;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _startCheckInProcess();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startCheckInProcess() async {
    setState(() {
      _currentStep = CheckInStep.acquiringLocation;
      _statusMessage = 'Acquiring your location...';
    });

    try {
      // Check location permission
      final locationPermission = await Permission.location.request();
      if (locationPermission != PermissionStatus.granted) {
        setState(() {
          _statusMessage = 'Location permission required';
          _currentStep = CheckInStep.error;
        });
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentStep = CheckInStep.validatingLocation;
        _statusMessage = 'Validating location...';
      });

      // Validate geofence
      final isInGeofence = await ref.read(checkInProvider.notifier).validateGeofence(
        widget.sessionId,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (!isInGeofence) {
        setState(() {
          _statusMessage = 'You are not within the designated class area';
          _currentStep = CheckInStep.error;
        });
        return;
      }

      // Initialize camera for facial recognition
      await _initializeCamera();
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Error acquiring location: $e';
        _currentStep = CheckInStep.error;
      });
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _currentStep = CheckInStep.initializingCamera;
      _statusMessage = 'Initializing camera...';
    });

    try {
      final permission = await Permission.camera.request();
      if (permission != PermissionStatus.granted) {
        setState(() {
          _statusMessage = 'Camera permission required';
          _currentStep = CheckInStep.error;
        });
        return;
      }

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
      
      setState(() {
        _isCameraInitialized = true;
        _currentStep = CheckInStep.readyToCapture;
        _statusMessage = 'Position your face within the frame and tap to check in';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize camera: $e';
        _currentStep = CheckInStep.error;
      });
    }
  }

  Future<void> _performFacialRecognition() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _currentStep = CheckInStep.processing;
      _statusMessage = 'Verifying your identity...';
    });

    try {
      final image = await _cameraController!.takePicture();
      
      final result = await ref.read(checkInProvider.notifier).performCheckIn(
        widget.sessionId,
        image.path,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (result.isSuccess) {
        setState(() {
          _currentStep = CheckInStep.success;
          _statusMessage = 'Check-in successful!';
        });
        
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check-in successful! Attendance marked for ${result.courseName}'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      } else {
        setState(() {
          _currentStep = CheckInStep.error;
          _statusMessage = result.errorMessage ?? 'Check-in failed';
        });
      }
    } catch (e) {
      setState(() {
        _currentStep = CheckInStep.error;
        _statusMessage = 'Error during facial recognition: $e';
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
      message: _statusMessage,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Check In',
          showLogout: false,
        ),
        body: Column(
          children: [
            // Status Bar
            _buildStatusBar(),
            
            // Main Content
            Expanded(
              child: _buildMainContent(),
            ),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    Color statusColor;
    IconData statusIcon;
    
    switch (_currentStep) {
      case CheckInStep.success:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case CheckInStep.error:
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      case CheckInStep.readyToCapture:
        statusColor = AppColors.primary;
        statusIcon = Icons.camera_alt;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      color: statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentStep == CheckInStep.readyToCapture || _currentStep == CheckInStep.processing) {
      return _buildCameraView();
    } else if (_currentStep == CheckInStep.success) {
      return _buildSuccessView();
    } else if (_currentStep == CheckInStep.error) {
      return _buildErrorView();
    } else {
      return _buildLoadingView();
    }
  }

  Widget _buildCameraView() {
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
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Instructions
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Text(
              'Position your face within the oval guide and tap "Check In Now" when ready.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
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
            'Check-in Successful!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your attendance has been recorded.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 100.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 24.h),
            Text(
              'Check-in Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 24.h),
          Text(
            _statusMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              onPressed: () => context.pop(),
              backgroundColor: AppColors.grey400,
            ),
          ),
          if (_currentStep == CheckInStep.readyToCapture) ...[
            SizedBox(width: 16.w),
            Expanded(
              child: CustomButton(
                text: 'Check In Now',
                onPressed: _isProcessing ? null : _performFacialRecognition,
                icon: const Icon(Icons.camera_alt),
              ),
            ),
          ],
          if (_currentStep == CheckInStep.error) ...[
            SizedBox(width: 16.w),
            Expanded(
              child: CustomButton(
                text: 'Retry',
                onPressed: () {
                  setState(() {
                    _currentStep = CheckInStep.initializing;
                  });
                  _startCheckInProcess();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum CheckInStep {
  initializing,
  acquiringLocation,
  validatingLocation,
  initializingCamera,
  readyToCapture,
  processing,
  success,
  error,
}