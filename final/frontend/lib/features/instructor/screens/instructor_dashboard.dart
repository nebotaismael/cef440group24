import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../providers/instructor_providers.dart';

class InstructorDashboard extends ConsumerWidget {
  const InstructorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final courses = ref.watch(instructorCoursesProvider);
    final activeSessions = ref.watch(instructorActiveSessionsProvider);
    final todayStats = ref.watch(instructorTodayStatsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Instructor Dashboard'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(instructorCoursesProvider);
          ref.invalidate(instructorActiveSessionsProvider);
          ref.invalidate(instructorTodayStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, user.fullName),
              SizedBox(height: 16.h),
              
              // Today's Stats
              _buildSectionTitle(context, 'Today\'s Overview'),
              SizedBox(height: 8.h),
              todayStats.when(
                data: (stats) => _buildTodayStatsCard(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load today\'s stats'),
              ),
              
              SizedBox(height: 24.h),
              
              // Active Sessions
              _buildSectionTitle(context, 'Active Sessions'),
              SizedBox(height: 8.h),
              activeSessions.when(
                data: (sessions) => sessions.isEmpty
                    ? _buildEmptyState('No active sessions')
                    : Column(
                        children: sessions
                            .map((session) => _buildActiveSessionCard(context, session))
                            .toList(),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load active sessions'),
              ),
              
              SizedBox(height: 24.h),
              
              // My Courses
              _buildSectionTitle(context, 'My Courses'),
              SizedBox(height: 8.h),
              courses.when(
                data: (courseList) => courseList.isEmpty
                    ? _buildEmptyState('No courses assigned')
                    : Column(
                        children: courseList
                            .map((course) => _buildCourseCard(context, course))
                            .toList(),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load courses'),
              ),
              
              SizedBox(height: 24.h),
              
              // Quick Actions
              _buildQuickActions(context),
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
            colors: [AppColors.secondary, AppColors.secondaryLight],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
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
              'Manage your classes and monitor attendance',
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

  Widget _buildTodayStatsCard(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Sessions\nConducted', stats['sessionsToday'], AppColors.primary),
                _buildStatItem(context, 'Total\nAttendance', stats['totalAttendance'], AppColors.success),
                _buildStatItem(context, 'Average\nRate', '${stats['averageRate']}%', AppColors.info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActiveSessionCard(BuildContext context, Map<String, dynamic> session) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success,
          child: Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(session['courseName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Started: ${session['startTime']}'),
            Text('Location: ${session['location']}'),
            Text('Present: ${session['presentCount']}/${session['totalStudents']}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'monitor':
                context.push('/instructor/monitor/${session['id']}');
                break;
              case 'end':
                _showEndSessionDialog(context, session['id']);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'monitor',
              child: Row(
                children: [
                  Icon(Icons.monitor),
                  SizedBox(width: 8),
                  Text('Monitor'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'end',
              child: Row(
                children: [
                  Icon(Icons.stop_circle, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('End Session'),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            course['courseCode'].substring(0, 2),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(course['courseName']),
        subtitle: Text('Code: ${course['courseCode']}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => context.push('/instructor/session-management/${course['id']}'),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Quick Actions'),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => context.push('/instructor/reports'),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assessment,
                          size: 32.sp,
                          color: AppColors.secondary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Reports',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => context.push('/profile'),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          size: 32.sp,
                          color: AppColors.secondary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 48.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  void _showEndSessionDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement end session functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session ended successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}