import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../providers/instructor_providers.dart';

class RealTimeMonitorScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const RealTimeMonitorScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<RealTimeMonitorScreen> createState() => _RealTimeMonitorScreenState();
}

class _RealTimeMonitorScreenState extends ConsumerState<RealTimeMonitorScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data every 30 seconds for real-time updates
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        ref.invalidate(sessionDetailsProvider(widget.sessionId));
        _startPeriodicRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionDetails = ref.watch(sessionDetailsProvider(widget.sessionId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Monitor Attendance',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(sessionDetailsProvider(widget.sessionId));
            },
          ),
        ],
      ),
      body: sessionDetails.when(
        data: (details) {
          if (details.isEmpty) {
            return const Center(child: Text('Session not found'));
          }
          return _buildMonitorContent(details);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: AppColors.error),
              SizedBox(height: 16.h),
              Text('Failed to load session details'),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.invalidate(sessionDetailsProvider(widget.sessionId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonitorContent(Map<String, dynamic> details) {
    final students = details['students'] as List<Map<String, dynamic>>;
    final presentCount = details['presentCount'] as int;
    final totalStudents = details['totalStudents'] as int;

    return Column(
      children: [
        // Session Info Header
        _buildSessionHeader(details),
        
        // Attendance Summary
        _buildAttendanceSummary(presentCount, totalStudents),
        
        // Student List
        Expanded(
          child: _buildStudentList(students),
        ),
        
        // Action Buttons
        _buildActionButtons(details),
      ],
    );
  }

  Widget _buildSessionHeader(Map<String, dynamic> details) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${details['courseCode']} - ${details['courseName']}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Started: ${details['startTime']} | Location: ${details['location']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'ACTIVE SESSION',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(int presentCount, int totalStudents) {
    final attendanceRate = totalStudents > 0 ? (presentCount / totalStudents * 100).round() : 0;
    
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Present',
                presentCount.toString(),
                AppColors.success,
                Icons.check_circle,
              ),
            ),
            Container(
              width: 1,
              height: 40.h,
              color: AppColors.grey300,
            ),
            Expanded(
              child: _buildSummaryItem(
                'Absent',
                (totalStudents - presentCount).toString(),
                AppColors.error,
                Icons.cancel,
              ),
            ),
            Container(
              width: 1,
              height: 40.h,
              color: AppColors.grey300,
            ),
            Expanded(
              child: _buildSummaryItem(
                'Rate',
                '$attendanceRate%',
                attendanceRate >= 75 ? AppColors.success : AppColors.warning,
                Icons.assessment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> students) {
    if (students.isEmpty) {
      return const Center(
        child: Text('No students enrolled in this course'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final isPresent = student['status'] == 'present';
    final isOverridden = student['isOverridden'] == true;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPresent ? AppColors.success : AppColors.error,
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(
          student['fullName'],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${student['matriculeNumber']}'),
            if (isPresent && student['checkInTime'] != null)
              Text(
                'Check-in: ${student['checkInTime']}',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12.sp,
                ),
              ),
            if (isOverridden)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Override: ${student['overrideJustification']}',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 10.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'override') {
              context.push('/instructor/override/${widget.sessionId}/${student['id']}');
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'override',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18),
                  SizedBox(width: 8.w),
                  const Text('Manual Override'),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: isOverridden,
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> details) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Generate Report',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report generation feature coming soon'),
                  ),
                );
              },
              backgroundColor: AppColors.info,
              icon: const Icon(Icons.assessment),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              text: 'End Session',
              onPressed: () => _showEndSessionDialog(),
              backgroundColor: AppColors.error,
              icon: const Icon(Icons.stop),
            ),
          ),
        ],
      ),
    );
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text(
          'Are you sure you want to end this session? Students will no longer be able to check in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endSession();
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _endSession() {
    // TODO: Implement end session functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session ended successfully'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }
}