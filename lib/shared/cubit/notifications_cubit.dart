import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/shared/models/notification_model.dart';
import 'package:honset_app/shared/repositories/notification_repository.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final bool isLoading;

  @override
  List<Object?> get props => [notifications, unreadCount, isLoading];

  NotificationsState copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  void watchNotifications(String userId) {
    _subscription?.cancel();
    emit(state.copyWith(isLoading: true));
    _subscription = _repository.watchNotifications(userId).listen((notifications) {
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
      ));
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
