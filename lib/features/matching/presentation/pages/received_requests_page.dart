import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/matching_bloc.dart';
import '../bloc/matching_event.dart';
import '../bloc/matching_state.dart';
import '../widgets/barter_request_card.dart';

/// Page for displaying barter requests received by user
class ReceivedRequestsPage extends StatefulWidget {
  const ReceivedRequestsPage({super.key});

  @override
  State<ReceivedRequestsPage> createState() => _ReceivedRequestsPageState();
}

class _ReceivedRequestsPageState extends State<ReceivedRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load all received requests on init
    context.read<MatchingBloc>().add(const MatchingLoadReceivedRequestsEvent());
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
        title: const Text('Received Requests'),
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
                  MatchingLoadReceivedRequestsEvent(status: status),
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
          } else if (state is MatchingRequestAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request accepted! The requester has been notified.'),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload requests
            context.read<MatchingBloc>().add(
                  const MatchingLoadReceivedRequestsEvent(),
                );
          } else if (state is MatchingRequestRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request rejected'),
                backgroundColor: AppColors.info,
              ),
            );
            // Reload requests
            context.read<MatchingBloc>().add(
                  const MatchingLoadReceivedRequestsEvent(),
                );
          }
        },
        builder: (context, state) {
          if (state is MatchingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MatchingEmpty) {
            return _buildEmptyState(state.message ?? 'No requests received yet');
          }

          if (state is MatchingRequestsLoaded &&
              (state.requestType == 'received' || state.requestType == null)) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MatchingBloc>().add(
                      const MatchingLoadReceivedRequestsEvent(),
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return BarterRequestCard(
                    request: request,
                    isReceived: true,
                    onTap: () {
                      // TODO: Navigate to details page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Details page coming soon'),
                        ),
                      );
                    },
                    onAccept: request.status.canAccept
                        ? () => _showAcceptDialog(context, request.id)
                        : null,
                    onReject: request.status.canReject
                        ? () => _showRejectDialog(context, request.id)
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
            Icons.inbox_outlined,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'When someone wants to barter with your property, requests will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Accept Request?'),
        content: const Text(
          'By accepting this request, you agree to exchange your property with the requester for the specified dates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MatchingBloc>().add(
                    MatchingAcceptRequestEvent(requestId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String requestId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this request?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Let them know why...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MatchingBloc>().add(
                    MatchingRejectRequestEvent(
                      requestId,
                      reason: reasonController.text.trim().isEmpty
                          ? null
                          : reasonController.text.trim(),
                    ),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
