import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  bool _isLoading = false;
  
  // Mock system settings
  Map<String, dynamic> _settings = {
    'facialRecognitionThreshold': 0.85,
    'checkInWindowStart': 10, // minutes before class
    'checkInWindowEnd': 15, // minutes after class start
    'sessionInactivityTimeout': 30, // minutes
    'offlineDataValidityPeriod': 24, // hours
    'defaultGeofenceTolerance': 10, // meters
    'maxFailedLoginAttempts': 3,
    'passwordMinLength': 6,
    'passwordRequireUppercase': true,
    'passwordRequireLowercase': true,
    'passwordRequireNumbers': true,
    'passwordRequireSpecialChars': false,
    'enableFacialRecognition': true,
    'enableGeofencing': true,
    'enableOfflineMode': true,
    'enableAuditLogging': true,
    'autoBackupFrequency': 24, // hours
    'dataRetentionPeriod': 365, // days
  };

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Saving settings...',
      child: Scaffold(
        appBar: const CustomAppBar(title: 'System Settings'),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Facial Recognition Settings
              _buildSettingsSection(
                'Facial Recognition Settings',
                Icons.face_retouching_natural,
                AppColors.primary,
                _buildFacialRecognitionSettings(),
              ),
              
              SizedBox(height: 16.h),
              
              // Attendance Settings
              _buildSettingsSection(
                'Attendance Settings',
                Icons.access_time,
                AppColors.success,
                _buildAttendanceSettings(),
              ),
              
              SizedBox(height: 16.h),
              
              // Security Settings
              _buildSettingsSection(
                'Security Settings',
                Icons.security,
                AppColors.error,
                _buildSecuritySettings(),
              ),
              
              SizedBox(height: 16.h),
              
              // System Features
              _buildSettingsSection(
                'System Features',
                Icons.settings,
                AppColors.info,
                _buildSystemFeatures(),
              ),
              
              SizedBox(height: 16.h),
              
              // Data Management
              _buildSettingsSection(
                'Data Management',
                Icons.storage,
                AppColors.warning,
                _buildDataManagementSettings(),
              ),
              
              SizedBox(height: 24.h),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, Color color, Widget content) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFacialRecognitionSettings() {
    return Column(
      children: [
        _buildSwitchSetting(
          'Enable Facial Recognition',
          'Allow users to check in using facial recognition',
          _settings['enableFacialRecognition'],
          (value) => setState(() => _settings['enableFacialRecognition'] = value),
        ),
        SizedBox(height: 12.h),
        _buildSliderSetting(
          'Recognition Threshold',
          'Similarity threshold for facial recognition (${(_settings['facialRecognitionThreshold'] * 100).toInt()}%)',
          _settings['facialRecognitionThreshold'],
          0.5,
          1.0,
          (value) => setState(() => _settings['facialRecognitionThreshold'] = value),
        ),
      ],
    );
  }

  Widget _buildAttendanceSettings() {
    return Column(
      children: [
        _buildNumberSetting(
          'Check-in Window Start',
          'Minutes before class that check-in becomes available',
          _settings['checkInWindowStart'],
          (value) => setState(() => _settings['checkInWindowStart'] = value),
          suffix: 'minutes',
        ),
        SizedBox(height: 12.h),
        _buildNumberSetting(
          'Check-in Window End',
          'Minutes after class start that check-in is still allowed',
          _settings['checkInWindowEnd'],
          (value) => setState(() => _settings['checkInWindowEnd'] = value),
          suffix: 'minutes',
        ),
        SizedBox(height: 12.h),
        _buildNumberSetting(
          'Default Geofence Tolerance',
          'Additional tolerance radius for geofence validation',
          _settings['defaultGeofenceTolerance'],
          (value) => setState(() => _settings['defaultGeofenceTolerance'] = value),
          suffix: 'meters',
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      children: [
        _buildNumberSetting(
          'Max Failed Login Attempts',
          'Number of failed attempts before account lockout',
          _settings['maxFailedLoginAttempts'],
          (value) => setState(() => _settings['maxFailedLoginAttempts'] = value),
          suffix: 'attempts',
        ),
        SizedBox(height: 12.h),
        _buildNumberSetting(
          'Password Minimum Length',
          'Minimum required password length',
          _settings['passwordMinLength'],
          (value) => setState(() => _settings['passwordMinLength'] = value),
          suffix: 'characters',
        ),
        SizedBox(height: 12.h),
        _buildSwitchSetting(
          'Require Uppercase Letters',
          'Password must contain uppercase letters',
          _settings['passwordRequireUppercase'],
          (value) => setState(() => _settings['passwordRequireUppercase'] = value),
        ),
        SizedBox(height: 8.h),
        _buildSwitchSetting(
          'Require Lowercase Letters',
          'Password must contain lowercase letters',
          _settings['passwordRequireLowercase'],
          (value) => setState(() => _settings['passwordRequireLowercase'] = value),
        ),
        SizedBox(height: 8.h),
        _buildSwitchSetting(
          'Require Numbers',
          'Password must contain numeric characters',
          _settings['passwordRequireNumbers'],
          (value) => setState(() => _settings['passwordRequireNumbers'] = value),
        ),
        SizedBox(height: 8.h),
        _buildSwitchSetting(
          'Require Special Characters',
          'Password must contain special characters',
          _settings['passwordRequireSpecialChars'],
          (value) => setState(() => _settings['passwordRequireSpecialChars'] = value),
        ),
      ],
    );
  }

  Widget _buildSystemFeatures() {
    return Column(
      children: [
        _buildSwitchSetting(
          'Enable Geofencing',
          'Use location-based validation for attendance',
          _settings['enableGeofencing'],
          (value) => setState(() => _settings['enableGeofencing'] = value),
        ),
        SizedBox(height: 8.h),
        _buildSwitchSetting(
          'Enable Offline Mode',
          'Allow attendance recording when offline',
          _settings['enableOfflineMode'],
          (value) => setState(() => _settings['enableOfflineMode'] = value),
        ),
        SizedBox(height: 8.h),
        _buildSwitchSetting(
          'Enable Audit Logging',
          'Log all system activities for security',
          _settings['enableAuditLogging'],
          (value) => setState(() => _settings['enableAuditLogging'] = value),
        ),
        SizedBox(height: 12.h),
        _buildNumberSetting(
          'Session Inactivity Timeout',
          'Minutes before inactive sessions are terminated',
          _settings['sessionInactivityTimeout'],
          (value) => setState(() => _settings['sessionInactivityTimeout'] = value),
          suffix: 'minutes',
        ),
      ],
    );
  }

  Widget _buildDataManagementSettings() {
    return Column(
      children: [
        _buildNumberSetting(
          'Auto Backup Frequency',
          'Hours between automatic system backups',
          _settings['autoBackupFrequency'],
          (value) => setState(() => _settings['autoBackupFrequency'] = value),
          suffix: 'hours',
        ),
        SizedBox(height: 12.h),
        _buildNumberSetting(
          'Data Retention Period',
          'Days to retain attendance and audit data',
          _settings['dataRetentionPeriod'],
          (value) => setState(() => _settings['dataRetentionPeriod'] = value),
          suffix: 'days',
        ),
        SizedBox(height: 12.h),
        _buildNumberSetting(
          'Offline Data Validity',
          'Hours that offline attendance data remains valid',
          _settings['offlineDataValidityPeriod'],
          (value) => setState(() => _settings['offlineDataValidityPeriod'] = value),
          suffix: 'hours',
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(String title, String description, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSliderSetting(String title, String description, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 50,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildNumberSetting(String title, String description, int value, Function(int) onChanged, {String? suffix}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => onChanged(value > 1 ? value - 1 : 1),
              icon: const Icon(Icons.remove),
              iconSize: 20.sp,
            ),
            Container(
              width: 60.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                suffix != null ? '$value $suffix' : value.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
              iconSize: 20.sp,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Reset to Defaults',
                onPressed: _resetToDefaults,
                backgroundColor: AppColors.grey400,
                icon: const Icon(Icons.restore),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomButton(
                text: 'Save Settings',
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _exportSettings,
            icon: const Icon(Icons.file_download),
            label: const Text('Export Settings'),
          ),
        ),
      ],
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _settings = {
                  'facialRecognitionThreshold': 0.85,
                  'checkInWindowStart': 10,
                  'checkInWindowEnd': 15,
                  'sessionInactivityTimeout': 30,
                  'offlineDataValidityPeriod': 24,
                  'defaultGeofenceTolerance': 10,
                  'maxFailedLoginAttempts': 3,
                  'passwordMinLength': 6,
                  'passwordRequireUppercase': true,
                  'passwordRequireLowercase': true,
                  'passwordRequireNumbers': true,
                  'passwordRequireSpecialChars': false,
                  'enableFacialRecognition': true,
                  'enableGeofencing': true,
                  'enableOfflineMode': true,
                  'enableAuditLogging': true,
                  'autoBackupFrequency': 24,
                  'dataRetentionPeriod': 365,
                };
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // Simulate saving settings
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _exportSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings exported successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}