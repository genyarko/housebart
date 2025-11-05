import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_routes.dart';
import '../../../matching/presentation/bloc/matching_bloc.dart';
import '../../../matching/presentation/bloc/matching_event.dart';
import '../../../matching/presentation/bloc/matching_state.dart';
import '../../../matching/presentation/widgets/barter_request_card.dart';

class MyBartersPage extends StatefulWidget {
  const MyBartersPage({super.key});

  @override
  State<MyBartersPage> createState() => _MyBartersPageState();
}

class _MyBartersPageState extends State<MyBartersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<MatchingBloc>().add(const MatchingLoadMyRequestsEvent());
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
        title: const Text('My Barters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Requests'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyRequestsTab(),
          _buildReceivedRequestsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'my_barters_page_fab',
        onPressed: () => context.push(AppRoutes.properties),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('New Barter'),
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    return BlocBuilder<MatchingBloc, MatchingState>(
      builder: (context, state) {
        if (state is MatchingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MatchingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MatchingBloc>().add(const MatchingLoadMyRequestsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is MatchingRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horizontal_circle_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No barter requests yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start bartering by browsing properties',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.properties),
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Properties'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MatchingBloc>().add(const MatchingLoadMyRequestsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BarterRequestCard(
                    request: request,
                    onTap: () {
                      // TODO: Navigate to barter request details
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request details coming soon')),
                      );
                    },
                    onCancel: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Cancel Request'),
                          content: const Text('Are you sure you want to cancel this barter request?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.read<MatchingBloc>().add(
                                      MatchingCancelRequestEvent(request.id),
                                    );
                              },
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildReceivedRequestsTab() {
    return BlocBuilder<MatchingBloc, MatchingState>(
      builder: (context, state) {
        if (state is MatchingLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MatchingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MatchingBloc>().add(const MatchingLoadReceivedRequestsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is MatchingRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No received requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When someone requests to barter with your property,\nit will appear here',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MatchingBloc>().add(const MatchingLoadReceivedRequestsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BarterRequestCard(
                    request: request,
                    isReceived: true,
                    onTap: () {
                      // TODO: Navigate to barter request details
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request details coming soon')),
                      );
                    },
                    onAccept: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Accept Request'),
                          content: const Text('Are you sure you want to accept this barter request?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.read<MatchingBloc>().add(
                                      MatchingAcceptRequestEvent(request.id),
                                    );
                              },
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      );
                    },
                    onReject: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          final reasonController = TextEditingController();
                          return AlertDialog(
                            title: const Text('Reject Request'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Please provide a reason for rejection:'),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: reasonController,
                                  decoration: const InputDecoration(
                                    hintText: 'Reason (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  context.read<MatchingBloc>().add(
                                        MatchingRejectRequestEvent(
                                          request.id,
                                          reason: reasonController.text.isEmpty
                                              ? null
                                              : reasonController.text,
                                        ),
                                      );
                                },
                                child: const Text('Reject'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
