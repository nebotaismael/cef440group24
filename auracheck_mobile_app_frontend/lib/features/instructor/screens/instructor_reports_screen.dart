import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../providers/instructor_providers.dart';

class InstructorReportsScreen extends ConsumerStatefulWidget {
  const InstructorReportsScreen({super.key});

  @override
  ConsumerState<InstructorReportsScreen> createState() => _InstructorReportsScreenState();
}

class _InstructorReportsScreenState extends ConsumerState<InstructorReportsScreen> {
  String? _selectedCourseId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(instructorCoursesProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Reports'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Configuration
              _buildReportConfiguration(courses),
              SizedBox(height: 24.h),

              // Quick Reports Section
              _buildQuickReportsSection(),
              SizedBox(height: 24.h),

              // Recent Reports (if any)
              _buildRecentReportsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportConfiguration(AsyncValue<List<Map<String, dynamic>>> courses) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Custom Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Course Selection
            courses.when(
              data: (courseList) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                value: _selectedCourseId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All My Courses', overflow: TextOverflow.ellipsis),
                  ),
                  ...courseList.map((course) => DropdownMenuItem<String>(
                    value: course['id'],
                    child: Text(
                      '${course['courseCode']} - ${course['courseName']}',
                      overflow: TextOverflow.ellipsis,
                    ),
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
                text: 'Generate Report',
                onPressed: _isGenerating ? null : _generateReport,
                isLoading: _isGenerating,
                icon: const Icon(Icons.assessment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Reports',
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
          childAspectRatio: 1.5,
          children: [
            _buildQuickReportCard(
              'Today\'s Sessions',
              Icons.today,
              AppColors.primary,
              () => _generateQuickReport('today'),
            ),
            _buildQuickReportCard(
              'This Week',
              Icons.view_week,
              AppColors.success,
              () => _generateQuickReport('week'),
            ),
            _buildQuickReportCard(
              'This Month',
              Icons.calendar_month,
              AppColors.info,
              () => _generateQuickReport('month'),
            ),
            _buildQuickReportCard(
              'Overall Summary',
              Icons.summarize,
              AppColors.warning,
              () => _generateQuickReport('overall'),
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
                size: 32.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildRecentReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48.sp,
                  color: AppColors.grey400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No recent reports',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Generated reports will appear here for easy access.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
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

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      // Simulate report generation
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully! Check your downloads.'),
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
      case 'today':
        message = 'Today\'s attendance report generated!';
        break;
      case 'week':
        message = 'Weekly attendance report generated!';
        break;
      case 'month':
        message = 'Monthly attendance report generated!';
        break;
      case 'overall':
        message = 'Overall summary report generated!';
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
}
