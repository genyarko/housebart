import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_routes.dart';
import '../bloc/property_bloc.dart';
import '../bloc/property_event.dart';
import '../bloc/property_state.dart';
import '../widgets/property_card.dart';

/// Page for displaying list of all properties
class PropertiesListPage extends StatefulWidget {
  const PropertiesListPage({super.key});

  @override
  State<PropertiesListPage> createState() => _PropertiesListPageState();
}

class _PropertiesListPageState extends State<PropertiesListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load properties on init
    context.read<PropertyBloc>().add(const PropertyLoadRequested());

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<PropertyBloc>().state;
      if (state is PropertiesLoaded && state.hasMore) {
        context.read<PropertyBloc>().add(
              PropertyLoadRequested(
                offset: state.currentOffset,
                loadMore: true,
              ),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon')),
              );
            },
          ),
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter feature coming soon')),
              );
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
          }
        },
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PropertiesEmpty) {
            return _buildEmptyState(state.message ?? 'No properties found');
          }

          if (state is PropertiesLoaded || state is PropertiesLoadingMore) {
            final propertiesState = state as PropertiesLoaded;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PropertyBloc>().add(const PropertyLoadRequested());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: propertiesState.properties.length +
                           (state is PropertiesLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loading indicator at the end
                  if (index >= propertiesState.properties.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final property = propertiesState.properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertyCard(
                      property: property,
                      onTap: () {
                        context.push(
                          '${AppRoutes.propertyDetails}/${property.id}',
                        );
                      },
                      onFavorite: () {
                        // TODO: Add to favorites
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Favorites feature coming soon'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return _buildEmptyState('Something went wrong');
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'properties_list_page_fab',
        onPressed: () {
          context.push(AppRoutes.addProperty);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push(AppRoutes.addProperty);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Property'),
          ),
        ],
      ),
    );
  }
}
