import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(authProvider.notifier).login(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (result.isSuccess) {
        // Navigation will be handled by GoRouter redirect
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Login failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Signing in...',
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    Icon(
                      Icons.school,
                      size: 80.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'AuraCheck',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Attendance Management System',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 48.h),
            
                    // Login Form
                    CustomTextField(
                      label: 'Matricule Number / Staff ID / Email',
                      hint: 'Enter your identifier',
                      controller: _identifierController,
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your identifier';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
            
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
            
                    CustomButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 16.h),
            
                    TextButton(
                      onPressed: () => context.push('/password-reset'),
                      child: const Text('Forgot Password?'),
                    ),
                    SizedBox(height: 32.h),
            
                    // Demo Credentials
                    Card(
                      color: AppColors.grey50,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demo Credentials:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            _buildDemoCredential('Student', 'FE22A256', 'Any password'),
                            _buildDemoCredential('Instructor', 'INS001', 'Any password'),
                            _buildDemoCredential('Admin', 'ADM001', 'Any password'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredential(String role, String id, String password) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(
        '$role: $id / $password',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}