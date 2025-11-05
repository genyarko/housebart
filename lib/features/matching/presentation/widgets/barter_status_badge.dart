import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/barter_request.dart';

/// Widget to display barter request status as a badge
class BarterStatusBadge extends StatelessWidget {
  final BarterRequestStatus status;
  final bool showIcon;

  const BarterStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getStatusIcon(),
              size: 16,
              color: _getStatusColor(),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case BarterRequestStatus.pending:
        return AppColors.warning;
      case BarterRequestStatus.accepted:
        return AppColors.success;
      case BarterRequestStatus.rejected:
        return AppColors.error;
      case BarterRequestStatus.cancelled:
        return AppColors.textSecondary;
      case BarterRequestStatus.completed:
        return AppColors.info;
      case BarterRequestStatus.expired:
        return AppColors.textSecondary.withOpacity(0.7);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case BarterRequestStatus.pending:
        return Icons.pending_outlined;
      case BarterRequestStatus.accepted:
        return Icons.check_circle_outline;
      case BarterRequestStatus.rejected:
        return Icons.cancel_outlined;
      case BarterRequestStatus.cancelled:
        return Icons.block_outlined;
      case BarterRequestStatus.completed:
        return Icons.done_all;
      case BarterRequestStatus.expired:
        return Icons.access_time;
    }
  }
}
