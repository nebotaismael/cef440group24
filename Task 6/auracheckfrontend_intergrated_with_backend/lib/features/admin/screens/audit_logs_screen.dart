import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  final _searchController = TextEditingController();
  String? _selectedEventType;
  String? _selectedOutcome;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _eventTypes = [
    'All Events',
    'User Login',
    'Password Change',
    'Facial Enrollment',
    'Attendance Check-in',
    'Manual Override',
    'User Management',
    'Course Management',
    'Geofence Management',
    'System Settings',
  ];

  final List<String> _outcomes = ['All', 'Success', 'Failure'];

  // Mock audit log data
  final List<Map<String, dynamic>> _mockAuditLogs = [
    {
      'id': '1',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'userId': 'FE22A256',
      'userName': 'Nebota Ismael',
      'eventType': 'Attendance Check-in',
      'affectedResource': 'Session: CEF440-001',
      'outcome': 'Success',
      'ipAddress': '192.168.1.100',
      'context': 'Facial recognition successful, geofence validated',
    },
    {
      'id': '2',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'userId': 'INS001',
      'userName': 'Dr. Nkemeni Valery',
      'eventType': 'Manual Override',
      'affectedResource': 'Student: FE22A199',
      'outcome': 'Success',
      'ipAddress': '192.168.1.101',
      'context': 'Override attendance for legitimate absence',
    },
    {
      'id': '3',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'userId': 'ADM001',
      'userName': 'System Administrator',
      'eventType': 'User Management',
      'affectedResource': 'User: FE22A176',
      'outcome': 'Success',
      'ipAddress': '192.168.1.102',
      'context': 'Created new student account',
    },
    {
      'id': '4',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'userId': 'FE22A214',
      'userName': 'Eyong Godwill Ngang',
      'eventType': 'User Login',
      'affectedResource': 'User Session',
      'outcome': 'Failure',
      'ipAddress': '192.168.1.103',
      'context': 'Invalid password provided',
    },
    {
      'id': '5',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'userId': 'INS001',
      'userName': 'Dr. Nkemeni Valery',
      'eventType': 'Course Management',
      'affectedResource': 'Course: CEF440',
      'outcome': 'Success',
      'ipAddress': '192.168.1.101',
      'context': 'Updated course description',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _getFilteredLogs();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Audit Logs'),
      body: Column(
        children: [
          // Filters Section
          _buildFiltersSection(),
          
          // Logs List
          Expanded(
            child: filteredLogs.isEmpty
                ? _buildEmptyState()
                : _buildLogsList(filteredLogs),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Audit Logs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Search Bar
            CustomTextField(
              controller: _searchController,
              hint: 'Search by user, event, or resource...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {});
              },
            ),
            
            SizedBox(height: 12.h),
            
            // Event Type Filter
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Event Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedEventType ?? 'All Events',
                    items: _eventTypes.map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: TextStyle(fontSize: 12.sp)),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEventType = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Outcome',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedOutcome ?? 'All',
                    items: _outcomes.map((outcome) => DropdownMenuItem<String>(
                      value: outcome,
                      child: Text(outcome),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOutcome = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Date Range Filter
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectStartDate(context),
                    child: Text(
                      _startDate != null
                          ? 'From: ${DateFormat('dd/MM').format(_startDate!)}'
                          : 'Start Date',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectEndDate(context),
                    child: Text(
                      _endDate != null
                          ? 'To: ${DateFormat('dd/MM').format(_endDate!)}'
                          : 'End Date',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Filters',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList(List<Map<String, dynamic>> logs) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogCard(log);
      },
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final isSuccess = log['outcome'] == 'Success';
    final eventColor = _getEventTypeColor(log['eventType']);
    
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isSuccess ? AppColors.success : AppColors.error,
          radius: 12.r,
          child: Icon(
            isSuccess ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16.sp,
          ),
        ),
        title: Text(
          log['eventType'],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: eventColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: ${log['userName']} (${log['userId']})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Time: ${_formatTimestamp(log['timestamp'])}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: (isSuccess ? AppColors.success : AppColors.error).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            log['outcome'],
            style: TextStyle(
              color: isSuccess ? AppColors.success : AppColors.error,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Log ID', log['id']),
                _buildDetailRow('Affected Resource', log['affectedResource']),
                _buildDetailRow('IP Address', log['ipAddress']),
                _buildDetailRow('Full Timestamp', _formatFullTimestamp(log['timestamp'])),
                SizedBox(height: 8.h),
                Text(
                  'Context:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    log['context'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No audit logs found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Adjust your filters to see relevant logs.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredLogs() {
    var logs = List<Map<String, dynamic>>.from(_mockAuditLogs);
    
    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      logs = logs.where((log) =>
          log['userName'].toLowerCase().contains(searchTerm) ||
          log['userId'].toLowerCase().contains(searchTerm) ||
          log['eventType'].toLowerCase().contains(searchTerm) ||
          log['affectedResource'].toLowerCase().contains(searchTerm)
      ).toList();
    }
    
    // Event type filter
    if (_selectedEventType != null && _selectedEventType != 'All Events') {
      logs = logs.where((log) => log['eventType'] == _selectedEventType).toList();
    }
    
    // Outcome filter
    if (_selectedOutcome != null && _selectedOutcome != 'All') {
      logs = logs.where((log) => log['outcome'] == _selectedOutcome).toList();
    }
    
    // Date range filter
    if (_startDate != null || _endDate != null) {
      logs = logs.where((log) {
        final logDate = log['timestamp'] as DateTime;
        if (_startDate != null && logDate.isBefore(_startDate!)) return false;
        if (_endDate != null && logDate.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
        return true;
      }).toList();
    }
    
    // Sort by timestamp (most recent first)
    logs.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return logs;
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'User Login':
        return AppColors.primary;
      case 'Attendance Check-in':
        return AppColors.success;
      case 'Manual Override':
        return AppColors.warning;
      case 'User Management':
      case 'Course Management':
      case 'Geofence Management':
        return AppColors.info;
      case 'System Settings':
        return AppColors.secondary;
      default:
        return AppColors.grey600;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
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
      firstDate: _startDate ?? DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedEventType = null;
      _selectedOutcome = null;
      _startDate = null;
      _endDate = null;
    });
  }
}