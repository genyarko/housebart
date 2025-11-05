import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/barter_request.dart';
import 'barter_status_badge.dart';

/// Card widget for displaying a barter request
class BarterRequestCard extends StatelessWidget {
  final BarterRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final bool isReceived; // true if this is a received request, false if sent

  const BarterRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.isReceived = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isReceived ? 'Request from user' : 'Request to property owner',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  BarterStatusBadge(status: request.status),
                ],
              ),
              const SizedBox(height: 16),

              // Dates section
              _buildDatesSection(),
              const SizedBox(height: 16),

              // Guests info
              Row(
                children: [
                  Icon(Icons.people_outline, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Guests: ${request.requesterGuests} ⇄ ${request.ownerGuests}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              // Fair exchange indicator
              if (!request.isFairExchange) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Duration difference: ${(request.requestedDuration - request.offeredDuration).abs()} days',
                          style: TextStyle(fontSize: 13, color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Message if any
              if (request.message != null && request.message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.message_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.message!,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Expiration warning
              if (request.status.isPending && request.timeUntilExpiration != null) ...[
                const SizedBox(height: 12),
                _buildExpirationWarning(),
              ],

              // Action buttons
              if (_shouldShowActions()) ...[
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],

              // Timestamps
              const SizedBox(height: 12),
              Text(
                'Created ${_formatDate(request.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDateRow(
            label: 'You receive',
            start: request.requestedStartDate,
            end: request.requestedEndDate,
            duration: request.requestedDuration,
          ),
          const Divider(height: 24),
          _buildDateRow(
            label: 'You offer',
            start: request.offeredStartDate,
            end: request.offeredEndDate,
            duration: request.offeredDuration,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow({
    required String label,
    required DateTime start,
    required DateTime end,
    required int duration,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDateShort(start)} - ${_formatDateShort(end)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$duration ${duration == 1 ? 'day' : 'days'}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationWarning() {
    final hoursUntilExpiration = request.timeUntilExpiration!.inHours;
    final daysUntilExpiration = hoursUntilExpiration ~/ 24;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              daysUntilExpiration > 0
                  ? 'Expires in $daysUntilExpiration ${daysUntilExpiration == 1 ? 'day' : 'days'}'
                  : 'Expires in $hoursUntilExpiration ${hoursUntilExpiration == 1 ? 'hour' : 'hours'}',
              style: TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowActions() {
    if (isReceived && request.status.isPending) {
      return onAccept != null || onReject != null;
    }
    if (!isReceived && request.status.canCancel) {
      return onCancel != null;
    }
    return false;
  }

  Widget _buildActionButtons() {
    if (isReceived && request.status.isPending) {
      // Show accept/reject for received pending requests
      return Row(
        children: [
          if (onReject != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                ),
              ),
            ),
          if (onReject != null && onAccept != null) const SizedBox(width: 12),
          if (onAccept != null)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      );
    } else if (!isReceived && request.status.canCancel && onCancel != null) {
      // Show cancel for sent requests
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('Cancel Request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }
}
