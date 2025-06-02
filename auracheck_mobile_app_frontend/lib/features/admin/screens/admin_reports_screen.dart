import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../providers/admin_providers.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  String? _selectedCourseId;
  String? _selectedInstructorId;
  String? _selectedStudentId;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedStatus;
  bool _isGenerating = false;

  final List<String> _statusOptions = ['All', 'Present', 'Absent'];

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(allCoursesProvider());
    final instructors = ref.watch(instructorsListProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'System Reports'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Configuration
              _buildReportConfiguration(courses, instructors),
              SizedBox(height: 24.h),
              
              // Quick System Reports
              _buildQuickSystemReports(),
              SizedBox(height: 24.h),
              
              // Analytics Overview
              _buildAnalyticsOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportConfiguration(
    AsyncValue<List<Map<String, dynamic>>> courses,
    AsyncValue<List<Map<String, String>>> instructors,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Custom System Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Course Selection
            courses.when(
              data: (courseList) => DropdownButtonFormField<String>(isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Course (Optional)',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCourseId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Courses'),
                  ),
                  ...courseList.map((course) => DropdownMenuItem<String>(
                    value: course['id'],
                    child: Text('${course['courseCode']} - ${course['courseName']}'),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCourseId = value;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading courses'),
            ),
            
            SizedBox(height: 16.h),
            
            // Instructor Selection
            instructors.when(
              data: (instructorList) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Instructor (Optional)',
                  border: OutlineInputBorder(),
                ),
                value: _selectedInstructorId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Instructors'),
                  ),
                  ...instructorList.map((instructor) => DropdownMenuItem<String>(
                    value: instructor['id'],
                    child: Text('${instructor['name']} (${instructor['staffId']})'),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedInstructorId = value;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading instructors'),
            ),
            
            SizedBox(height: 16.h),
            
            // Attendance Status Filter
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Attendance Status',
                border: OutlineInputBorder(),
              ),
              value: _selectedStatus ?? 'All',
              items: _statusOptions.map((status) => DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Date Range Selection
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectStartDate(context),
                    child: Text(
                      _startDate != null
                          ? 'From: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                          : 'Start Date',
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectEndDate(context),
                    child: Text(
                      _endDate != null
                          ? 'To: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                          : 'End Date',
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Generate Comprehensive Report',
                onPressed: _isGenerating ? null : _generateCustomReport,
                isLoading: _isGenerating,
                icon: const Icon(Icons.analytics),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSystemReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick System Reports',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 1.3,
          children: [
            _buildQuickReportCard(
              'Daily Summary',
              Icons.today,
              AppColors.primary,
              () => _generateQuickReport('daily'),
            ),
            _buildQuickReportCard(
              'Weekly Analysis',
              Icons.view_week,
              AppColors.success,
              () => _generateQuickReport('weekly'),
            ),
            _buildQuickReportCard(
              'Monthly Overview',
              Icons.calendar_month,
              AppColors.info,
              () => _generateQuickReport('monthly'),
            ),
            _buildQuickReportCard(
              'System Health',
              Icons.health_and_safety,
              AppColors.warning,
              () => _generateQuickReport('health'),
            ),
            _buildQuickReportCard(
              'User Activity',
              Icons.people_alt,
              AppColors.secondary,
              () => _generateQuickReport('activity'),
            ),
            _buildQuickReportCard(
              'Course Statistics',
              Icons.school,
              AppColors.surfaceVariant,
              () => _generateQuickReport('courses'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickReportCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 28.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverview() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Analytics Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Analytics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 2.5,
              children: [
                _buildAnalyticsItem('Total Sessions', '156', Icons.play_circle, AppColors.primary),
                _buildAnalyticsItem('Avg Attendance', '87%', Icons.trending_up, AppColors.success),
                _buildAnalyticsItem('Active Users', '234', Icons.people, AppColors.info),
                _buildAnalyticsItem('System Uptime', '99.8%', Icons.schedule, AppColors.warning),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Export Options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportData('csv'),
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export CSV'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportData('pdf'),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _generateCustomReport() async {
    setState(() => _isGenerating = true);

    try {
      // Simulate comprehensive report generation
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comprehensive system report generated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateQuickReport(String type) async {
    String message;
    switch (type) {
      case 'daily':
        message = 'Daily summary report generated!';
        break;
      case 'weekly':
        message = 'Weekly analysis report generated!';
        break;
      case 'monthly':
        message = 'Monthly overview report generated!';
        break;
      case 'health':
        message = 'System health report generated!';
        break;
      case 'activity':
        message = 'User activity report generated!';
        break;
      case 'courses':
        message = 'Course statistics report generated!';
        break;
      default:
        message = 'Report generated successfully!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _exportData(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data exported as ${format.toUpperCase()} successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

