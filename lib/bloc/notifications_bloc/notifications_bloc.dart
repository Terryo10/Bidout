import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      // Simulate API call with dummy data
      await Future.delayed(const Duration(seconds: 1));
      final notifications = _getDummyNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  void _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications =
          currentState.notifications.map((notification) {
        if (notification.id == event.notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
      emit(NotificationsLoaded(updatedNotifications));
    }
  }

  void _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = currentState.notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
      emit(NotificationsLoaded(updatedNotifications));
    }
  }

  List<Notification> _getDummyNotifications() {
    return [
      Notification(
        id: '1',
        title: 'New Project Posted',
        message: 'A new project matching your skills has been posted.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'info',
      ),
      Notification(
        id: '2',
        title: 'Bid Accepted',
        message: 'Your bid for "Kitchen Renovation" has been accepted!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'success',
      ),
      Notification(
        id: '3',
        title: 'Project Update',
        message: 'The timeline for "Bathroom Remodel" has been updated.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'warning',
      ),
      Notification(
        id: '4',
        title: 'Payment Received',
        message:
            'Payment of \$1,500 has been received for "Deck Construction".',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'success',
      ),
      Notification(
        id: '5',
        title: 'Contract Expiring',
        message: 'Your contract for "Office Renovation" expires in 7 days.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'warning',
      ),
    ];
  }
}
