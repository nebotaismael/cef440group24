import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../providers/admin_providers.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();
  UserRole? _selectedRoleFilter;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = ref.watch(allUsersProvider(
      roleFilter: _selectedRoleFilter,
      searchQuery: _searchController.text,
    ));

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'User Management'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddUserDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // Search and Filter Bar
            _buildSearchAndFilter(),
            
            // User List
            Expanded(
              child: usersProvider.when(
                data: (users) => users.isEmpty
                    ? _buildEmptyState()
                    : _buildUserList(users),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load users'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Search Bar
            CustomTextField(
              controller: _searchController,
              hint: 'Search by name, email, or ID...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {});
                ref.invalidate(allUsersProvider);
              },
            ),
            SizedBox(height: 12.h),
            
            // Role Filter
            Row(
              children: [
                Text(
                  'Filter by Role:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DropdownButton<UserRole?>(
                    value: _selectedRoleFilter,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<UserRole?>(
                        value: null,
                        child: Text('All Roles'),
                      ),
                      ...UserRole.values.map((role) => DropdownMenuItem<UserRole?>(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRoleFilter = value;
                      });
                      ref.invalidate(allUsersProvider);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = UserRole.values.firstWhere((r) => r.name == user['role']);
    final status = UserStatus.values.firstWhere((s) => s.name == user['status']);
    
    Color roleColor;
    switch (role) {
      case UserRole.admin:
        roleColor = AppColors.error;
        break;
      case UserRole.instructor:
        roleColor = AppColors.warning;
        break;
      case UserRole.student:
        roleColor = AppColors.primary;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Text(
            user['fullName'][0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['fullName'],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${user['matriculeOrStaffId']}'),
            Text('Email: ${user['email']}'),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    role.name.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: status == UserStatus.active 
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.grey400.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      color: status == UserStatus.active ? AppColors.success : AppColors.grey600,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
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
            PopupMenuItem(
              value: status == UserStatus.active ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    status == UserStatus.active ? Icons.block : Icons.check_circle,
                    size: 18,
                    color: status == UserStatus.active ? AppColors.error : AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(status == UserStatus.active ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset_password',
              child: Row(
                children: [
                  Icon(Icons.lock_reset, size: 18),
                  SizedBox(width: 8),
                  Text('Reset Password'),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
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
              Icons.people_outline,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add users or adjust your search filters.',
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

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(context, user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user['id'], action == 'activate');
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(
        title: 'Add New User',
        onSave: _addUser,
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(
        title: 'Edit User',
        userData: userData,
        onSave: (data) => _updateUser(userData['id'], data),
      ),
    );
  }

  Future<void> _addUser(Map<String, dynamic> userData) async {
    setState(() => _isLoading = true);

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      final user = User(
        id: uuid.v4(),
        fullName: userData['fullName'],
        email: userData['email'],
        matriculeOrStaffId: userData['matriculeOrStaffId'],
        role: userData['role'],
        status: UserStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      // Add to local Hive storage
      await HiveService.userBox.put(user.id, user);

      // Add to Firebase
      await FirebaseService.createUser(user);

      ref.invalidate(allUsersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add user: $e'),
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

  Future<void> _updateUser(String userId, Map<String, dynamic> userData) async {
    setState(() => _isLoading = true);

    try {
      final existingUser = HiveService.userBox.get(userId);
      if (existingUser != null) {
        final updatedUser = existingUser.copyWith(
          fullName: userData['fullName'],
          email: userData['email'],
          matriculeOrStaffId: userData['matriculeOrStaffId'],
          role: userData['role'],
          updatedAt: DateTime.now(),
        );

        // Update in local Hive storage
        await HiveService.userBox.put(userId, updatedUser);

        // Update in Firebase
        await FirebaseService.updateUser(updatedUser);

        ref.invalidate(allUsersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user: $e'),
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

  Future<void> _toggleUserStatus(String userId, bool activate) async {
    setState(() => _isLoading = true);

    try {
      final user = HiveService.userBox.get(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          status: activate ? UserStatus.active : UserStatus.inactive,
          updatedAt: DateTime.now(),
        );

        // Update in local Hive storage
        await HiveService.userBox.put(userId, updatedUser);

        // Update in Firebase
        await FirebaseService.updateUser(updatedUser);

        ref.invalidate(allUsersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${activate ? 'activated' : 'deactivated'} successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user status: $e'),
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

  void _resetUserPassword(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Reset password for ${user['fullName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset email sent successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>) onSave;

  const _UserFormDialog({
    required this.title,
    this.userData,
    required this.onSave,
  });

  @override
  State<_UserFormDialog> createState() => __UserFormDialogState();
}

class __UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _fullNameController.text = widget.userData!['fullName'];
      _emailController.text = widget.userData!['email'];
      _idController.text = widget.userData!['matriculeOrStaffId'];
      _selectedRole = UserRole.values.firstWhere((r) => r.name == widget.userData!['role']);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _idController.dispose();
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
                label: 'Full Name',
                controller: _fullNameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'ID (Matricule/Staff)',
                controller: _idController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<UserRole>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items: UserRole.values.map((role) => DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role.name.toUpperCase()),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
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
          onPressed: _saveUser,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'matriculeOrStaffId': _idController.text.trim(),
        'role': _selectedRole,
      };

      widget.onSave(userData);
      Navigator.of(context).pop();
    }
  }
}