import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';
import '../widgets/property_card.dart';

/// Page for displaying user's own properties
class MyPropertiesPage extends StatefulWidget {
  const MyPropertiesPage({super.key});

  @override
  State<MyPropertiesPage> createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  @override
  void initState() {
    super.initState();
    _loadUserProperties();
  }

  void _loadUserProperties() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PropertyBloc>().add(
            UserPropertiesLoadRequested(authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.push(AppRoutes.addProperty);
              // Reload properties if a new one was added
              if (result == true) {
                _loadUserProperties();
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PropertyDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Property deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload properties
            _loadUserProperties();
          } else if (state is PropertyStatusToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.property.isActive
                      ? 'Property activated'
                      : 'Property deactivated',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload properties
            _loadUserProperties();
          }
        },
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PropertiesEmpty) {
            return _buildEmptyState();
          }

          if (state is PropertiesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _loadUserProperties();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.properties.length,
                itemBuilder: (context, index) {
                  final property = state.properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPropertyCard(property),
                  );
                },
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'my_properties_page_fab',
        onPressed: () async {
          final result = await context.push(AppRoutes.addProperty);
          if (result == true) {
            _loadUserProperties();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }

  Widget _buildPropertyCard(property) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('${AppRoutes.propertyDetails}/${property.id}');
        },
        child: Column(
          children: [
            // Property card
            PropertyCard(
              property: property,
              onTap: () {
                context.push('${AppRoutes.propertyDetails}/${property.id}');
              },
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: AppColors.surfaceLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Edit button
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to edit page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),

                  // Toggle status button
                  TextButton.icon(
                    onPressed: () {
                      _showToggleStatusDialog(property);
                    },
                    icon: Icon(
                      property.isActive
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(property.isActive ? 'Deactivate' : 'Activate'),
                  ),

                  // Delete button
                  TextButton.icon(
                    onPressed: () {
                      _showDeleteDialog(property.id);
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'You have no properties yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first property to start bartering',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await context.push(AppRoutes.addProperty);
              if (result == true) {
                _loadUserProperties();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Property'),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusDialog(property) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(property.isActive ? 'Deactivate Property?' : 'Activate Property?'),
        content: Text(
          property.isActive
              ? 'This will hide your property from other users.'
              : 'This will make your property visible to other users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PropertyBloc>().add(
                    PropertyStatusToggleRequested(property.id),
                  );
            },
            child: Text(property.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String propertyId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this property?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PropertyBloc>().add(
                    PropertyDeleteRequested(propertyId),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
