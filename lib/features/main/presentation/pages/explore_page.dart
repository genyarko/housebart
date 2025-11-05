import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_routes.dart';
import '../../../property/presentation/bloc/property_bloc.dart';
import '../../../property/presentation/bloc/property_event.dart';
import '../../../property/presentation/bloc/property_state.dart';
import '../../../property/presentation/widgets/property_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../saved_properties/presentation/bloc/saved_property_bloc.dart';
import '../../../saved_properties/presentation/bloc/saved_property_event.dart';
import '../../../saved_properties/presentation/bloc/saved_property_state.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // Cache the properties list so it persists even when bloc state changes
  List<dynamic> _cachedProperties = [];
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load properties and saved properties when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Load or reload property data
  void _loadData() {
    if (!mounted) return;
    context.read<PropertyBloc>().add(const PropertyLoadRequested());

    // Load saved properties - wrap in try-catch to handle errors gracefully
    try {
      context.read<SavedPropertyBloc>().add(const LoadSavedProperties());
    } catch (e) {
      // If saved properties fail to load, continue without them
      debugPrint('Error loading saved properties: $e');
    }
  }

  /// Public method to refresh data when page becomes visible
  void refreshData() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push(AppRoutes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: BlocListener<SavedPropertyBloc, SavedPropertyState>(
        listener: (context, savedState) {
          if (savedState is SavedPropertyActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(savedState.message)),
            );
          } else if (savedState is SavedPropertyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(savedState.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: BlocBuilder<PropertyBloc, PropertyState>(
                builder: (context, state) {
                // Update cache when we get a properties list
                if (state is PropertiesLoaded) {
                  _cachedProperties = state.properties;
                  _hasError = false;
                }

                // Track error state
                if (state is PropertyError) {
                  _hasError = true;
                  _errorMessage = state.message;
                }

                // Show loading only if we don't have cached data
                if (state is PropertyLoading && _cachedProperties.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error only if we don't have cached data
                if (_hasError && _cachedProperties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading properties',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PropertyBloc>().add(const PropertyLoadRequested());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Display cached properties regardless of current state
                if (_cachedProperties.isNotEmpty) {
                  final properties = _cachedProperties;

                  return CustomScrollView(
                    slivers: [
                      // Welcome header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${authState.user.firstName}! 👋',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Find your perfect property exchange',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Quick actions
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _QuickActionCard(
                                  icon: Icons.add_home,
                                  label: 'List Property',
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () => context.push(AppRoutes.addProperty),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionCard(
                                  icon: Icons.bookmark_outline,
                                  label: 'Saved',
                                  color: Theme.of(context).colorScheme.secondary,
                                  onTap: () => context.push(AppRoutes.savedProperties),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickActionCard(
                                  icon: Icons.home_outlined,
                                  label: 'My Properties',
                                  color: Theme.of(context).colorScheme.tertiary,
                                  onTap: () => context.push(AppRoutes.myProperties),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available Properties',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              TextButton(
                                onPressed: () => context.push(AppRoutes.properties),
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Properties grid
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: BlocBuilder<SavedPropertyBloc, SavedPropertyState>(
                          builder: (context, savedState) {
                            final savedStatusCache = savedState is SavedPropertyLoaded
                                ? savedState.savedStatusCache
                                : <String, bool>{};

                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final property = properties[index];
                                  final isFavorite = savedStatusCache[property.id] ?? false;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: PropertyCard(
                                      property: property,
                                      onTap: () {
                                        context.push('${AppRoutes.propertyDetails}/${property.id}');
                                      },
                                      onFavorite: () {
                                        context.read<SavedPropertyBloc>().add(
                                              ToggleSaveProperty(propertyId: property.id),
                                            );
                                      },
                                      isFavorite: isFavorite,
                                    ),
                                  );
                                },
                                childCount: properties.length,
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom spacing
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 16),
                      ),
                    ],
                  );
                }

                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'explore_page_fab',
        onPressed: () => context.push(AppRoutes.addProperty),
        icon: const Icon(Icons.add),
        label: const Text('List Property'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
