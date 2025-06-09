import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/geofence.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/loading_overlay.dart';
import '../providers/admin_providers.dart';

class GeofenceManagementScreen extends ConsumerStatefulWidget {
  const GeofenceManagementScreen({super.key});

  @override
  ConsumerState<GeofenceManagementScreen> createState() => _GeofenceManagementScreenState();
}

class _GeofenceManagementScreenState extends ConsumerState<GeofenceManagementScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final geofencesProvider = ref.watch(allGeofencesProvider(
      searchQuery: _searchController.text,
    ));

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Geofence Management'),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddGeofenceDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // Search Bar
            _buildSearchBar(),
            
            // Geofence List
            Expanded(
              child: geofencesProvider.when(
                data: (geofences) => geofences.isEmpty
                    ? _buildEmptyState()
                    : _buildGeofenceList(geofences),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState('Failed to load geofences'),
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
          hint: 'Search geofences by name...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            setState(() {});
            ref.invalidate(allGeofencesProvider);
          },
        ),
      ),
    );
  }

  Widget _buildGeofenceList(List<Map<String, dynamic>> geofences) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: geofences.length,
      itemBuilder: (context, index) {
        final geofence = geofences[index];
        return _buildGeofenceCard(geofence);
      },
    );
  }

  Widget _buildGeofenceCard(Map<String, dynamic> geofence) {
    final isActive = geofence['isActive'] as bool;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? AppColors.success : AppColors.grey400,
          child: Icon(
            Icons.location_on,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Text(
          geofence['name'],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.success : AppColors.grey400).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                isActive ? 'ACTIVE' : 'INACTIVE',
                style: TextStyle(
                  color: isActive ? AppColors.success : AppColors.grey600,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text('Radius: ${geofence['radius']}m'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleGeofenceAction(value, geofence),
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
              value: isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.toggle_off : Icons.toggle_on,
                    size: 18,
                    color: isActive ? AppColors.error : AppColors.success,
                  ),
                  SizedBox(width: 8),
                  Text(isActive ? 'Deactivate' : 'Activate'),
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
                _buildInfoRow('Coordinates', '${geofence['latitude']}, ${geofence['longitude']}'),
                _buildInfoRow('Radius', '${geofence['radius']} meters'),
                _buildInfoRow('Status', isActive ? 'Active' : 'Inactive'),
                _buildInfoRow('Created', _formatDate(DateTime.parse(geofence['createdAt'].toString()))),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Map Preview:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Interactive map feature coming soon',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
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
              Icons.location_off,
              size: 64.sp,
              color: AppColors.grey400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No geofences found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add geofences to define class locations.',
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

  void _handleGeofenceAction(String action, Map<String, dynamic> geofence) {
    switch (action) {
      case 'edit':
        _showEditGeofenceDialog(context, geofence);
        break;
      case 'activate':
      case 'deactivate':
        _toggleGeofenceStatus(geofence['id'], action == 'activate');
        break;
      case 'delete':
        _showDeleteConfirmation(context, geofence);
        break;
    }
  }

  void _showAddGeofenceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GeofenceFormDialog(
        title: 'Add New Geofence',
        onSave: _addGeofence,
      ),
    );
  }

  void _showEditGeofenceDialog(BuildContext context, Map<String, dynamic> geofenceData) {
    showDialog(
      context: context,
      builder: (context) => _GeofenceFormDialog(
        title: 'Edit Geofence',
        geofenceData: geofenceData,
        onSave: (data) => _updateGeofence(geofenceData['id'], data),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> geofence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text('Are you sure you want to delete "${geofence['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteGeofence(geofence['id']);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _addGeofence(Map<String, dynamic> geofenceData) async {
    setState(() => _isLoading = true);

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      final geofence = Geofence(
        id: uuid.v4(),
        name: geofenceData['name'],
        latitude: geofenceData['latitude'],
        longitude: geofenceData['longitude'],
        radius: geofenceData['radius'],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      // Add to local Hive storage
      await HiveService.geofenceBox.put(geofence.id, geofence);

      // Add to Firebase
      await FirebaseService.createGeofence(geofence);

      ref.invalidate(allGeofencesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geofence added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add geofence: $e'),
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

  Future<void> _updateGeofence(String geofenceId, Map<String, dynamic> geofenceData) async {
    setState(() => _isLoading = true);

    try {
      final existingGeofence = HiveService.geofenceBox.get(geofenceId);
      if (existingGeofence != null) {
        final updatedGeofence = existingGeofence.copyWith(
          name: geofenceData['name'],
          latitude: geofenceData['latitude'],
          longitude: geofenceData['longitude'],
          radius: geofenceData['radius'],
          updatedAt: DateTime.now(),
        );

        // Update in local Hive storage
        await HiveService.geofenceBox.put(geofenceId, updatedGeofence);

        // Update in Firebase
        await FirebaseService.updateGeofence(updatedGeofence);

        ref.invalidate(allGeofencesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geofence updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update geofence: $e'),
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

  Future<void> _toggleGeofenceStatus(String geofenceId, bool activate) async {
    setState(() => _isLoading = true);

    try {
      final geofence = HiveService.geofenceBox.get(geofenceId);
      if (geofence != null) {
        final updatedGeofence = geofence.copyWith(
          isActive: activate,
          updatedAt: DateTime.now(),
        );

        // Update in local Hive storage
        await HiveService.geofenceBox.put(geofenceId, updatedGeofence);

        // Update in Firebase
        await FirebaseService.updateGeofence(updatedGeofence);

        ref.invalidate(allGeofencesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Geofence ${activate ? 'activated' : 'deactivated'} successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update geofence status: $e'),
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

  Future<void> _deleteGeofence(String geofenceId) async {
    setState(() => _isLoading = true);

    try {
      // Delete from local Hive storage
      await HiveService.geofenceBox.delete(geofenceId);

      // Delete from Firebase
      await FirebaseService.getGeofenceById(geofenceId).then((geofence) async {
        if (geofence != null) {
          await FirebaseFirestore.instance
              .collection('geofences')
              .doc(geofenceId)
              .delete();
        }
      });

      ref.invalidate(allGeofencesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geofence deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete geofence: $e'),
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}

class _GeofenceFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? geofenceData;
  final Function(Map<String, dynamic>) onSave;

  const _GeofenceFormDialog({
    required this.title,
    this.geofenceData,
    required this.onSave,
  });

  @override
  State<_GeofenceFormDialog> createState() => __GeofenceFormDialogState();
}

class __GeofenceFormDialogState extends State<_GeofenceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.geofenceData != null) {
      _nameController.text = widget.geofenceData!['name'];
      _latitudeController.text = widget.geofenceData!['latitude'].toString();
      _longitudeController.text = widget.geofenceData!['longitude'].toString();
      _radiusController.text = widget.geofenceData!['radius'].toString();
    } else {
      // Default values for University of Buea
      _latitudeController.text = '4.1644';
      _longitudeController.text = '9.2816';
      _radiusController.text = '50';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
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
                label: 'Geofence Name',
                controller: _nameController,
                hint: 'e.g., FET Amphitheater 101',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter geofence name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Latitude',
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Required';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomTextField(
                      label: 'Longitude',
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Required';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                label: 'Radius (meters)',
                controller: _radiusController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter radius';
                  }
                  final radius = double.tryParse(value!);
                  if (radius == null || radius <= 0) {
                    return 'Please enter a valid radius';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppColors.info,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Tip: Use GPS coordinates app or Google Maps to get precise location coordinates.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
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
          onPressed: _saveGeofence,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveGeofence() {
    if (_formKey.currentState!.validate()) {
      final geofenceData = {
        'name': _nameController.text.trim(),
        'latitude': double.parse(_latitudeController.text.trim()),
        'longitude': double.parse(_longitudeController.text.trim()),
        'radius': double.parse(_radiusController.text.trim()),
      };

      widget.onSave(geofenceData);
      Navigator.of(context).pop();
    }
  }
}