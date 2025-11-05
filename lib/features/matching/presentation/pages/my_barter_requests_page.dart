import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/matching_bloc.dart';
import '../bloc/matching_event.dart';
import '../bloc/matching_state.dart';
import '../widgets/barter_request_card.dart';

/// Page for displaying user's sent barter requests
class MyBarterRequestsPage extends StatefulWidget {
  const MyBarterRequestsPage({super.key});

  @override
  State<MyBarterRequestsPage> createState() => _MyBarterRequestsPageState();
}

class _MyBarterRequestsPageState extends State<MyBarterRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load all requests on init
    context.read<MatchingBloc>().add(const MatchingLoadMyRequestsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            // Load filtered requests based on tab
            String? status;
            switch (index) {
              case 0:
                status = null; // All
                break;
              case 1:
                status = 'pending';
                break;
              case 2:
                status = 'accepted';
                break;
            }
            context.read<MatchingBloc>().add(
                  MatchingLoadMyRequestsEvent(status: status),
                );
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: BlocConsumer<MatchingBloc, MatchingState>(
        listener: (context, state) {
          if (state is MatchingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is MatchingRequestCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request cancelled successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload requests
            context.read<MatchingBloc>().add(
                  const MatchingLoadMyRequestsEvent(),
                );
          }
        },
        builder: (context, state) {
          if (state is MatchingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchingEmpty) {
            return _buildEmptyState(state.message ?? 'No requests found');
          }

          if (state is MatchingRequestsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MatchingBloc>().add(
                      const MatchingLoadMyRequestsEvent(),
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return BarterRequestCard(
                    request: request,
                    isReceived: false,
                    onTap: () {
                      // TODO: Navigate to details page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Details page coming soon'),
                        ),
                      );
                    },
                    onCancel: request.status.canCancel
                        ? () => _showCancelDialog(context, request.id)
                        : null,
                  );
                },
              ),
            );
          }

          return _buildEmptyState('Something went wrong');
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
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
          const SizedBox(height: 8),
          const Text(
            'Browse properties to start a barter',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to browse
            },
            icon: const Icon(Icons.search),
            label: const Text('Browse Properties'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text(
          'Are you sure you want to cancel this barter request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No, keep it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MatchingBloc>().add(
                    MatchingCancelRequestEvent(requestId),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }
}
