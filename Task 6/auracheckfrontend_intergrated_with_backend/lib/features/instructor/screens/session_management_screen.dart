import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/attendance_record.dart';
import '../../../core/models/session.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../providers/instructor_providers.dart';

class SessionManagementScreen extends ConsumerStatefulWidget {
  final String courseId;

  const SessionManagementScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends ConsumerState<SessionManagementScreen> {
  bool _isLoading = false;
  String? _selectedGeofenceId;

  @override
  Widget build(BuildContext context) {
    final course = HiveService.courseBox.get(widget.courseId);
    final activeSessions = ref.watch(instructorActiveSessionsProvider);
    
    if (course == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Session Management'),
        body: const Center(
          child: Text('Course not found'),
        ),
      );
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Starting session...',
      child: Scaffold(
        appBar: CustomAppBar(title: 'Manage ${course.courseCode}'),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info Card
              _buildCourseInfoCard(course),
              SizedBox(height: 16.h),
              
              // Active Session Check
              activeSessions.when(
                data: (sessions) {
                  final activeSession = sessions
                      .where((session) => session['courseId'] == widget.courseId)
                      .firstOrNull;
                  
                  if (activeSession != null) {
                    return _buildActiveSessionCard(activeSession);
                  } else {
                    return _buildStartSessionCard();
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorCard('Failed to load session status'),
              ),
              
              SizedBox(height: 24.h),
              
              // Recent Sessions
              _buildRecentSessionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard(dynamic course) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Course Code: ${course.courseCode}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (course.description.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                course.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard(Map<String, dynamic> session) {
    return Card(
      color: AppColors.success.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: AppColors.success,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Active Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text('Started: ${session['startTime']}'),
            Text('Location: ${session['location']}'),
            Text('Present: ${session['presentCount']}/${session['totalStudents']}'),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Monitor Attendance',
                    onPressed: () => context.push('/instructor/monitor/${session['id']}'),
                    icon: const Icon(Icons.monitor),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomButton(
                    text: 'End Session',
                    onPressed: () => _showEndSessionDialog(session['id']),
                    backgroundColor: AppColors.error,
                    icon: const Icon(Icons.stop),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSessionCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start New Session',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Geofence Selection
            Text(
              'Select Location (Geofence)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose a location',
              ),
              value: _selectedGeofenceId,
              items: HiveService.geofenceBox.values
                  .where((geofence) => geofence.isActive)
                  .map((geofence) => DropdownMenuItem<String>(
                    value: geofence.id,
                    child: Text(geofence.name),
                  ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGeofenceId = value;
                });
              },
            ),
            
            SizedBox(height: 16.h),
            
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Start Session',
                onPressed: _selectedGeofenceId != null ? _startSession : null,
                icon: const Icon(Icons.play_arrow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsSection() {
    // Get recent sessions for this course
    final recentSessions = HiveService.sessionBox.values
        .where((session) => session.courseId == widget.courseId)
        .where((session) => session.status == SessionStatus.ended)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final limitedSessions = recentSessions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        
        if (limitedSessions.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Center(
                child: Text(
                  'No recent sessions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
        else
          ...limitedSessions.map((session) => _buildRecentSessionCard(session)),
      ],
    );
  }

  Widget _buildRecentSessionCard(dynamic session) {
    final geofence = HiveService.geofenceBox.get(session.geofenceId);
    final attendanceRecords = HiveService.attendanceBox.values
        .where((record) => record.sessionId == session.id)
        .toList();
    
    final presentCount = attendanceRecords
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    
    final enrolledStudents = HiveService.enrollmentBox.get('course_${widget.courseId}') as List<String>? ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.grey600,
          child: Icon(
            Icons.history,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(_formatDate(session.startTime)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${geofence?.name ?? 'Unknown'}'),
            Text('Duration: ${_formatDuration(session.startTime, session.endTime)}'),
            Text('Attendance: $presentCount/${enrolledStudents.length}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.assessment),
          onPressed: () {
            // Navigate to session report or details
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Session details feature coming soon'),
              ),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: AppColors.error.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: AppColors.error,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    if (_selectedGeofenceId == null) return;

    setState(() => _isLoading = true);

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      final session = Session(
        id: uuid.v4(),
        courseId: widget.courseId,
        startTime: now,
        geofenceId: _selectedGeofenceId!,
        status: SessionStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      await HiveService.sessionBox.put(session.id, session);
      
      // Refresh the provider
      ref.invalidate(instructorActiveSessionsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session started successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate to monitor screen
        context.push('/instructor/monitor/${session.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start session: $e'),
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

  void _showEndSessionDialog(String sessionId) {
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
            onPressed: () async {
              Navigator.of(context).pop();
              await _endSession(sessionId);
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _endSession(String sessionId) async {
    setState(() => _isLoading = true);

    try {
      final session = HiveService.sessionBox.get(sessionId);
      if (session != null) {
        final updatedSession = session.copyWith(
          endTime: DateTime.now(),
          status: SessionStatus.ended,
          updatedAt: DateTime.now(),
        );
        
        await HiveService.sessionBox.put(sessionId, updatedSession);
        
        // Refresh the provider
        ref.invalidate(instructorActiveSessionsProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session ended successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end session: $e'),
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

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return 'Ongoing';
    
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}