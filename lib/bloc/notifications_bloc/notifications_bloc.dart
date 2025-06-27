import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      // TODO: Implement loading notifications from repository
      emit(const NotificationsLoaded([]));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications =
            currentState.notifications.map((notification) {
          if (notification.id == event.id) {
            return notification.copyWith(readAt: DateTime.now());
          }
          return notification;
        }).toList();

        emit(NotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      if (state is NotificationsLoaded) {
        final currentState = state as NotificationsLoaded;
        final updatedNotifications = currentState.notifications
            .map(
                (notification) => notification.copyWith(readAt: DateTime.now()))
            .toList();

        emit(NotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  List<Notification> _getDummyNotifications() {
    final now = DateTime.now();
    return [
      Notification(
        id: 1,
        userId: 1,
        type: 'new_project',
        data: const {
          'message': 'A new project matching your skills has been posted.',
          'title': 'New Project Posted'
        },
        createdAt: now.subtract(const Duration(minutes: 5)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
      Notification(
        id: 2,
        userId: 1,
        type: 'bid_accepted',
        data: const {
          'message': 'Your bid for "Kitchen Renovation" has been accepted!',
          'title': 'Bid Accepted'
        },
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Notification(
        id: 3,
        userId: 1,
        type: 'project_update',
        data: const {
          'message': 'The timeline for "Bathroom Remodel" has been updated.',
          'title': 'Project Update'
        },
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      Notification(
        id: 4,
        userId: 1,
        type: 'payment_received',
        data: const {
          'message':
              'Payment of \$1,500 has been received for "Deck Construction".',
          'title': 'Payment Received'
        },
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Notification(
        id: 5,
        userId: 1,
        type: 'contract_expiring',
        data: const {
          'message': 'Your contract for "Office Renovation" expires in 7 days.',
          'title': 'Contract Expiring'
        },
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
