import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isChangingPassword = false;
  bool _showPasswordForm = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider)!;

    return LoadingOverlay(
      isLoading: _isChangingPassword,
      message: 'Changing password...',
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Profile',
          showLogout: false,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(user),
              SizedBox(height: 24.h),
              
              // Personal Information
              _buildPersonalInfoSection(user),
              SizedBox(height: 24.h),
              
              // Role-specific Information
              _buildRoleSpecificSection(user),
              SizedBox(height: 24.h),
              
              // Security Section
              _buildSecuritySection(),
              SizedBox(height: 24.h),
              
              // App Information
              _buildAppInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    Color roleColor;
    IconData roleIcon;
    
    switch (user.role) {
      case UserRole.student:
        roleColor = AppColors.primary;
        roleIcon = Icons.school;
        break;
      case UserRole.instructor:
        roleColor = AppColors.warning;
        roleIcon = Icons.person_outline;
        break;
      case UserRole.admin:
        roleColor = AppColors.error;
        roleIcon = Icons.admin_panel_settings;
        break;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundColor: roleColor,
              child: Icon(
                roleIcon,
                size: 40.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                user.role.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('Full Name', user.fullName),
            _buildInfoRow('Email', user.email),
            _buildInfoRow(
              user.role == UserRole.student ? 'Matricule Number' : 'Staff ID',
              user.matriculeOrStaffId,
            ),
            _buildInfoRow('Account Status', user.status.name.toUpperCase()),
            _buildInfoRow('Member Since', _formatDate(user.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSpecificSection(User user) {
    switch (user.role) {
      case UserRole.student:
        return _buildStudentSection(user);
      case UserRole.instructor:
        return _buildInstructorSection();
      case UserRole.admin:
        return _buildAdminSection();
    }
  }

  Widget _buildStudentSection(User user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              'Facial Template',
              user.hasFacialTemplate ? 'Enrolled' : 'Not Enrolled',
              valueColor: user.hasFacialTemplate ? AppColors.success : AppColors.error,
            ),
            if (!user.hasFacialTemplate) ...[
              SizedBox(height: 12.h),
              CustomButton(
                text: 'Complete Facial Enrollment',
                onPressed: () => context.push('/student/facial-enrollment'),
                backgroundColor: AppColors.warning,
                icon: const Icon(Icons.face_retouching_natural),
              ),
            ],
            if (user.hasFacialTemplate) ...[
              SizedBox(height: 12.h),
              CustomButton(
                text: 'Re-enroll Facial Data',
                onPressed: () => context.push('/student/facial-enrollment'),
                backgroundColor: AppColors.info,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructorSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructor Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'My Courses',
                    onPressed: () => context.push('/instructor'),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.school),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'Reports',
                    onPressed: () => context.push('/instructor/reports'),
                    backgroundColor: AppColors.info,
                    icon: const Icon(Icons.assessment),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administrator Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Admin Panel',
                    onPressed: () => context.push('/admin'),
                    backgroundColor: AppColors.primary,
                    icon: const Icon(Icons.admin_panel_settings),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'System Reports',
                    onPressed: () => context.push('/admin/reports'),
                    backgroundColor: AppColors.info,
                    icon: const Icon(Icons.analytics),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            if (!_showPasswordForm) ...[
              CustomButton(
                text: 'Change Password',
                onPressed: () {
                  setState(() {
                    _showPasswordForm = true;
                  });
                },
                backgroundColor: AppColors.warning,
                icon: const Icon(Icons.lock),
              ),
            ] else ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Current Password',
                      controller: _currentPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter current password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter new password';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please confirm new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () {
                              setState(() {
                                _showPasswordForm = false;
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                              });
                            },
                            backgroundColor: AppColors.grey400,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: CustomButton(
                            text: 'Update',
                            onPressed: _changePassword,
                            isLoading: _isChangingPassword,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow('App Version', '1.0.0'),
            _buildInfoRow('Build Number', '1'),
            _buildInfoRow('Developer', 'Group 24 - UB FET'),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Privacy Policy'),
                          content: const Text(
                            'Your privacy is important to us. This app collects facial biometric data solely for attendance verification purposes. All data is encrypted and stored securely.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Privacy Policy'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Help & Support'),
                          content: const Text(
                            'For technical support or questions about the app, please contact the IT department at support@ub.edu.cm',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Help & Support'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);

    try {
      final success = await ref.read(authProvider.notifier).changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (success) {
        setState(() {
          _showPasswordForm = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to change password. Please check your current password.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}