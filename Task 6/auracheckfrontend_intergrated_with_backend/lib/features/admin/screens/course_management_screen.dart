import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/course.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../providers/admin_providers.dart';

class CourseManagementScreen extends ConsumerStatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  ConsumerState<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends ConsumerState<CourseManagementScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesProvider = ref.watch(allCoursesProvider(
      searchQuery: _searchController.text,
    ));
    final instructorsProvider = ref.watch(instructorsListProvider);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Course Management'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCourseDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            
            // Course List
            Expanded(
              child: coursesProvider.when(
                data: (courses) => courses.isEmpty
                    ? _buildEmptyState()
                    : _buildCourseList(courses, instructorsProvider),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load courses'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: CustomTextField(
          controller: _searchController,
          hint: 'Search courses by code or name...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            setState(() {});
            ref.invalidate(allCoursesProvider);
          },
        ),
      ),
    );
  }

  Widget _buildCourseList(
    List<Map<String, dynamic>> courses,
    AsyncValue<List<Map<String, dynamic>>> instructorsProvider,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course, instructorsProvider);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, AsyncValue<List<Map<String, dynamic>>> instructorsProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ExpansionTile(
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
        title: Text(
          '${course['courseCode']} - ${course['courseName']}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text('Instructor: ${course['instructorName']}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCourseAction(value, course, instructorsProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'enrollments',
              child: Row(
                children: [
                  Icon(Icons.people, size: 18),
                  SizedBox(width: 8),
                  Text('Manage Enrollments'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  course['description'].isNotEmpty ? course['description'] : 'No description available',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 12.h),
                FutureBuilder<Map<String, dynamic>>(
                  future: ref.read(courseEnrollmentDetailsProvider(course['id']).future),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final enrollmentData = snapshot.data!;
                      return Text(
                        'Enrolled Students: ${enrollmentData['totalEnrolled']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const Text('Loading enrollment data...');
                  },
                ),
              ],
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
              Icons.school_outlined,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No courses found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add courses or adjust your search filters.',
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleCourseAction(String action, Map<String, dynamic> course, AsyncValue<List<Map<String, dynamic>>> instructorsProvider) {
    switch (action) {
      case 'edit':
        _showEditCourseDialog(context, course, instructorsProvider);
        break;
      case 'enrollments':
        _showEnrollmentDialog(context, course);
        break;
      case 'delete':
        _showDeleteConfirmation(context, course);
        break;
    }
  }

  void _showAddCourseDialog(BuildContext context) {
    final instructorsProvider = ref.read(instructorsListProvider);
    showDialog(
      context: context,
      builder: (context) => _CourseFormDialog(
        title: 'Add New Course',
        instructorsProvider: instructorsProvider,
        onSave: _addCourse,
      ),
    );
  }

  void _showEditCourseDialog(BuildContext context, Map<String, dynamic> courseData, AsyncValue<List<Map<String, dynamic>>> instructorsProvider) {
    showDialog(
      context: context,
      builder: (context) => _CourseFormDialog(
        title: 'Edit Course',
        courseData: courseData,
        instructorsProvider: instructorsProvider,
        onSave: (data) => _updateCourse(courseData['id'], data),
      ),
    );
  }

  void _showEnrollmentDialog(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => _EnrollmentManagementDialog(courseId: course['id']),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course['courseCode']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCourse(course['id']);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCourse(Map<String, dynamic> courseData) async {
    setState(() => _isLoading = true);

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      final course = Course(
        id: uuid.v4(),
        courseCode: courseData['courseCode'],
        courseName: courseData['courseName'],
        description: courseData['description'],
        instructorId: courseData['instructorId'],
        createdAt: now,
        updatedAt: now,
      );

      // Add to local Hive storage
      await HiveService.courseBox.put(course.id, course);

      // Add to Firebase
      await FirebaseService.addCourse(course);

      ref.invalidate(allCoursesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add course: $e'),
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

  Future<void> _updateCourse(String courseId, Map<String, dynamic> courseData) async {
    setState(() => _isLoading = true);

    try {
      final existingCourse = HiveService.courseBox.get(courseId);
      if (existingCourse != null) {
        final updatedCourse = existingCourse.copyWith(
          courseCode: courseData['courseCode'],
          courseName: courseData['courseName'],
          description: courseData['description'],
          instructorId: courseData['instructorId'],
          updatedAt: DateTime.now(),
        );

        // Update in local Hive storage
        await HiveService.courseBox.put(courseId, updatedCourse);

        // Update in Firebase
        await FirebaseService.updateCourse(updatedCourse);

        ref.invalidate(allCoursesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update course: $e'),
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

  Future<void> _deleteCourse(String courseId) async {
    setState(() => _isLoading = true);

    try {
      // Delete from local Hive storage
      await HiveService.courseBox.delete(courseId);

      // Delete from Firebase
      await FirebaseService.deleteCourse(courseId);

      // Also remove enrollments from local storage
      await HiveService.enrollmentBox.delete('course_$courseId');

      ref.invalidate(allCoursesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete course: $e'),
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
}

class _CourseFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? courseData;
  final AsyncValue<List<Map<String, dynamic>>> instructorsProvider;
  final Function(Map<String, dynamic>) onSave;

  const _CourseFormDialog({
    required this.title,
    this.courseData,
    required this.instructorsProvider,
    required this.onSave,
  });

  @override
  State<_CourseFormDialog> createState() => __CourseFormDialogState();
}

class __CourseFormDialogState extends State<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedInstructorId;

  @override
  void initState() {
    super.initState();
    if (widget.courseData != null) {
      _courseCodeController.text = widget.courseData!['courseCode'];
      _courseNameController.text = widget.courseData!['courseName'];
      _descriptionController.text = widget.courseData!['description'];
      _selectedInstructorId = widget.courseData!['instructorId'];
    }
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Course Code',
                controller: _courseCodeController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter course code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Course Name',
                controller: _courseNameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter course name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: 16.h),
              widget.instructorsProvider.when(
                data: (instructors) {
                  // Check if selectedInstructorId exists in the instructors list
                  bool instructorExists = instructors.any((instructor) => instructor['id'] == _selectedInstructorId);

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Instructor',
                      border: OutlineInputBorder(),
                    ),
                    value: instructorExists ? _selectedInstructorId : null,
                    items: instructors.map((instructor) => DropdownMenuItem<String>(
                      value: instructor['id'],
                      child: Text('${instructor['fullName']} (${instructor['matriculeOrStaffId']})'),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedInstructorId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an instructor';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading instructors'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCourse,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveCourse() {
    if (_formKey.currentState!.validate()) {
      final courseData = {
        'courseCode': _courseCodeController.text.trim(),
        'courseName': _courseNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'instructorId': _selectedInstructorId!,
      };

      widget.onSave(courseData);
      Navigator.of(context).pop();
    }
  }
}

class _EnrollmentManagementDialog extends ConsumerWidget {
  final String courseId;

  const _EnrollmentManagementDialog({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentDetails = ref.watch(courseEnrollmentDetailsProvider(courseId));

    return AlertDialog(
      title: const Text('Manage Enrollments'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400.h,
        child: enrollmentDetails.when(
          data: (data) {
            final course = data['course'] as Map<String, dynamic>;
            final students = data['enrolledStudents'] as List<Map<String, dynamic>>;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course['courseCode']} - ${course['courseName']}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text('Total Enrolled: ${students.length}'),
                SizedBox(height: 16.h),
                Expanded(
                  child: students.isEmpty
                      ? const Center(child: Text('No students enrolled'))
                      : ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return ListTile(
                              title: Text(student['fullName']),
                              subtitle: Text('ID: ${student['matriculeNumber']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: AppColors.error),
                                onPressed: () {
                                  // TODO: Implement unenroll functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Unenroll functionality coming soon'),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Center(child: Text('Error loading enrollment data')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // TODO: Implement add student functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add student functionality coming soon'),
              ),
            );
          },
          child: const Text('Add Students'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}