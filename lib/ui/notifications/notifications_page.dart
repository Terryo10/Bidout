import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/notifications_bloc/notifications_bloc.dart';
import '../../constants/app_colors.dart';
import '../../models/notification.dart' as models;

@RoutePage()
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Notifications',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
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
                              child: const Text(
                                'Mark all read',
                                style: TextStyle(
                                  color: AppColors.white,
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
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
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
                            style: const TextStyle(color: AppColors.error),
                          ),
                        );
                      }

                      if (state is NotificationsLoaded) {
                        if (state.notifications.isEmpty) {
                          return const Center(
                            child: Text(
                              'No notifications yet',
                              style: TextStyle(
                                color: AppColors.textSecondary,
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
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
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
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
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
        color = AppColors.success;
        break;
      case 'warning':
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case 'error':
        icon = Icons.error;
        color = AppColors.error;
        break;
      default:
        icon = Icons.info;
        color = AppColors.info;
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
