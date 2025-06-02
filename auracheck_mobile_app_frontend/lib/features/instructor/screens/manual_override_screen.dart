import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';

class ManualOverrideScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String studentId;

  const ManualOverrideScreen({
    super.key,
    required this.sessionId,
    required this.studentId,
  });

  @override
  ConsumerState<ManualOverrideScreen> createState() => _ManualOverrideScreenState();
}

class _ManualOverrideScreenState extends ConsumerState<ManualOverrideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _justificationController = TextEditingController();
  AttendanceStatus? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  void _loadCurrentStatus() {
    final existingRecord = HiveService.attendanceBox.values
        .where((record) => record.sessionId == widget.sessionId && record.studentId == widget.studentId)
        .firstOrNull;
    
    if (existingRecord != null) {
      setState(() {
        _selectedStatus = existingRecord.status;
        if (existingRecord.overrideJustification != null) {
          _justificationController.text = existingRecord.overrideJustification!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = HiveService.userBox.get(widget.studentId);
    final session = HiveService.sessionBox.get(widget.sessionId);
    final course = session != null ? HiveService.courseBox.get(session.courseId) : null;

    if (student == null || session == null || course == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Manual Override'),
        body: const Center(child: Text('Student, session, or course not found')),
      );
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Updating attendance...',
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Manual Override'),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student and Session Info
                _buildInfoCard(student, course, session),
                SizedBox(height: 24.h),
                
                // Current Status
                _buildCurrentStatusCard(),
                SizedBox(height: 24.h),
                
                // Override Form
                Expanded(
                  child: _buildOverrideForm(),
                ),
                
                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(dynamic student, dynamic course, dynamic session) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Override Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow('Student', student.fullName),
            _buildInfoRow('ID', student.matriculeOrStaffId),
            _buildInfoRow('Course', '${course.courseCode} - ${course.courseName}'),
            _buildInfoRow('Session', _formatDateTime(session.startTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final existingRecord = HiveService.attendanceBox.values
        .where((record) => record.sessionId == widget.sessionId && record.studentId == widget.studentId)
        .firstOrNull;

    return Card(
      color: existingRecord != null 
          ? (existingRecord.status == AttendanceStatus.present ? AppColors.success : AppColors.error).withOpacity(0.1)
          : AppColors.grey100,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  existingRecord?.status == AttendanceStatus.present ? Icons.check_circle : Icons.cancel,
                  color: existingRecord?.status == AttendanceStatus.present ? AppColors.success : AppColors.error,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  existingRecord?.status.name.toUpperCase() ?? 'ABSENT',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: existingRecord?.status == AttendanceStatus.present ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            if (existingRecord?.checkInTimestamp != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Check-in time: ${_formatDateTime(existingRecord!.checkInTimestamp!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (existingRecord?.isOverridden == true) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Override:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    Text(
                      existingRecord!.overrideJustification ?? 'No justification provided',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildOverrideForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Attendance Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Status Selection
          Row(
            children: [
              Expanded(
                child: RadioListTile<AttendanceStatus>(
                  title: const Text('Present'),
                  value: AttendanceStatus.present,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  activeColor: AppColors.success,
                ),
              ),
              Expanded(
                child: RadioListTile<AttendanceStatus>(
                  title: const Text('Absent'),
                  value: AttendanceStatus.absent,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  activeColor: AppColors.error,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24.h),
          
          // Justification
          CustomTextField(
            label: 'Justification for Override *',
            hint: 'Please provide a reason for this attendance override',
            controller: _justificationController,
            maxLines: 4,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Justification is required for manual override';
              }
              if (value!.trim().length < 10) {
                return 'Please provide a more detailed justification (at least 10 characters)';
              }
              return null;
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Warning Note
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppColors.warning,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'This override will be logged in the system audit trail and cannot be undone.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              onPressed: () => context.pop(),
              backgroundColor: AppColors.grey400,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: CustomButton(
              text: 'Apply Override',
              onPressed: _selectedStatus != null ? _applyOverride : null,
              icon: const Icon(Icons.save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyOverride() async {
    if (!_formKey.currentState!.validate() || _selectedStatus == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final instructor = ref.read(currentUserProvider);
      if (instructor == null) {
        throw Exception('Instructor not found');
      }

      // Find existing record or create new one
      final existingRecord = HiveService.attendanceBox.values
          .where((record) => record.sessionId == widget.sessionId && record.studentId == widget.studentId)
          .firstOrNull;

      final now = DateTime.now();
      const uuid = Uuid();

      AttendanceRecord newRecord;

      if (existingRecord != null) {
        // Update existing record
        newRecord = existingRecord.copyWith(
          status: _selectedStatus!,
          checkInTimestamp: _selectedStatus == AttendanceStatus.present ? now : null,
          overrideJustification: _justificationController.text.trim(),
          overrideBy: instructor.id,
          updatedAt: now,
        );
        await HiveService.attendanceBox.put(existingRecord.id, newRecord);
      } else {
        // Create new record
        newRecord = AttendanceRecord(
          id: uuid.v4(),
          studentId: widget.studentId,
          sessionId: widget.sessionId,
          status: _selectedStatus!,
          checkInTimestamp: _selectedStatus == AttendanceStatus.present ? now : null,
          overrideJustification: _justificationController.text.trim(),
          overrideBy: instructor.id,
          createdAt: now,
          updatedAt: now,
        );
        await HiveService.attendanceBox.put(newRecord.id, newRecord);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Attendance override applied successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply override: $e'),
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

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}