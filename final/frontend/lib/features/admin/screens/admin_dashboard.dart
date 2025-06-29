import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../providers/admin_providers.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final systemStats = ref.watch(adminSystemStatsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Admin Dashboard'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminSystemStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, user.fullName),
              SizedBox(height: 16.h),
              
              // System Statistics
              _buildSectionTitle(context, 'System Overview'),
              SizedBox(height: 8.h),
              systemStats.when(
                data: (stats) => _buildSystemStatsGrid(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load system statistics'),
              ),
              
              SizedBox(height: 24.h),
              
              // Management Modules
              _buildSectionTitle(context, 'Management'),
              SizedBox(height: 8.h),
              _buildManagementGrid(context),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              _buildSectionTitle(context, 'Quick Actions'),
              SizedBox(height: 8.h),
              _buildQuickActionsGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String name) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Administrator',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Manage the AuraCheck system',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSystemStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 8.h,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          context,
          'Total Users',
          stats['totalUsers'].toString(),
          Icons.people,
          AppColors.primary,
        ),
        _buildStatCard(
          context,
          'Active Sessions',
          stats['activeSessions'].toString(),
          Icons.play_circle_filled,
          AppColors.success,
        ),
        _buildStatCard(
          context,
          'Total Courses',
          stats['totalCourses'].toString(),
          Icons.school,
          AppColors.info,
        ),
        _buildStatCard(
          context,
          'System Health',
          '${stats['systemHealth']}%',
          Icons.health_and_safety,
          stats['systemHealth'] >= 90 ? AppColors.success : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final managementItems = [
      {
        'title': 'User\nManagement',
        'icon': Icons.people,
        'color': AppColors.primary,
        'route': '/admin/users',
      },
      {
        'title': 'Course\nManagement',
        'icon': Icons.school,
        'color': AppColors.success,
        'route': '/admin/courses',
      },
      {
        'title': 'Geofence\nManagement',
        'icon': Icons.location_on,
        'color': AppColors.info,
        'route': '/admin/geofences',
      },
      {
        'title': 'System\nReports',
        'icon': Icons.assessment,
        'color': AppColors.warning,
        'route': '/admin/reports',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 8.h,
      childAspectRatio: 1.2,
      children: managementItems.map((item) => _buildManagementCard(
        context,
        item['title'] as String,
        item['icon'] as IconData,
        item['color'] as Color,
        item['route'] as String,
      )).toList(),
    );
  }

  Widget _buildManagementCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40.sp,
                color: color,
              ),
              SizedBox(height: 12.h),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final quickActions = [
      {
        'title': 'Audit Logs',
        'icon': Icons.history,
        'color': AppColors.secondary,
        'route': '/admin/audit-logs',
      },
      {
        'title': 'System\nSettings',
        'icon': Icons.settings,
        'color': AppColors.grey600,
        'route': '/admin/settings',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8.w,
      mainAxisSpacing: 8.h,
      childAspectRatio: 1.5,
      children: quickActions.map((item) => _buildQuickActionCard(
        context,
        item['title'] as String,
        item['icon'] as IconData,
        item['color'] as Color,
        item['route'] as String,
      )).toList(),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32.sp,
                color: color,
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

