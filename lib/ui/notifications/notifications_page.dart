import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/notifications_bloc/notifications_bloc.dart';
import '../../constants/app_theme_extension.dart';
import '../../models/notification.dart' as models;

@RoutePage()
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: context.colors.onPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Notifications',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    BlocBuilder<NotificationsBloc, NotificationsState>(
                      builder: (context, state) {
                        if (state is NotificationsLoaded) {
                          final hasUnread = state.notifications
                              .any((notification) => !notification.isRead);
                          if (hasUnread) {
                            return TextButton(
                              onPressed: () {
                                context
                                    .read<NotificationsBloc>()
                                    .add(MarkAllNotificationsAsRead());
                              },
                              child: Text(
                                'Mark all read',
                                style: TextStyle(
                                  color: context.colors.onPrimary,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox(width: 48);
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsInitial) {
                        context
                            .read<NotificationsBloc>()
                            .add(LoadNotifications());
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is NotificationsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is NotificationsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: TextStyle(color: context.error),
                          ),
                        );
                      }

                      if (state is NotificationsLoaded) {
                        if (state.notifications.isEmpty) {
                          return Center(
                            child: Text(
                              'No notifications yet',
                              style: TextStyle(
                                color: context.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.notifications.length,
                          itemBuilder: (context, index) {
                            final notification = state.notifications[index];
                            return _NotificationCard(
                                notification: notification);
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final models.Notification notification;

  const _NotificationCard({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context
                .read<NotificationsBloc>()
                .add(MarkNotificationAsRead(notification.id));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: notification.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: notification.isRead
                                  ? context.textSecondary
                                  : context.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead
                            ? context.textSecondary
                            : context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}

class _NotificationIcon extends StatelessWidget {
  final String type;

  const _NotificationIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'success':
        icon = Icons.check_circle;
        color = context.success;
        break;
      case 'warning':
        icon = Icons.warning;
        color = context.warning;
        break;
      case 'error':
        icon = Icons.error;
        color = context.error;
        break;
      default:
        icon = Icons.info;
        color = context.info;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}
