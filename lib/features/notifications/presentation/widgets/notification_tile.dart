import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'barter':
        return Icons.swap_horiz;
      case 'message':
        return Icons.message;
      case 'verification':
        return Icons.verified;
      case 'review':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'barter':
        return Colors.blue;
      case 'message':
        return Colors.green;
      case 'verification':
        return Colors.orange;
      case 'review':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Notification'),
              content: const Text('Are you sure you want to delete this notification?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        elevation: notification.isUnread ? 2 : 0,
        color: notification.isUnread
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : null,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForType(notification.type),
              color: color,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: notification.isUnread
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (notification.isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                timeago.format(notification.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (notification.isUnread)
                        ListTile(
                          leading: const Icon(Icons.mark_email_read),
                          title: const Text('Mark as read'),
                          onTap: () {
                            Navigator.pop(context);
                            onTap();
                          },
                        ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete'),
                        onTap: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
