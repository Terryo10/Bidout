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

}
