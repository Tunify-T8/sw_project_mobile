import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';
import 'notification_filter.dart';

/// State for the Activity > Notifications tab.
class NotificationsState {
  final bool isLoading;
  final bool isRefreshing;
  final List<NotificationEntity> items;
  final String? error;
  final NotificationFilter filter;
  final int unreadCount;

  const NotificationsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.items = const [],
    this.error,
    this.filter = NotificationFilter.all,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<NotificationEntity>? items,
    String? error,
    bool clearError = false,
    NotificationFilter? filter,
    int? unreadCount,
  }) =>
      NotificationsState(
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        items: items ?? this.items,
        error: clearError ? null : (error ?? this.error),
        filter: filter ?? this.filter,
        unreadCount: unreadCount ?? this.unreadCount,
      );
}

class NotificationsController extends Notifier<NotificationsState> {
  StreamSubscription<dynamic>? _pushSub;

  @override
  NotificationsState build() {
    ref.onDispose(() => _pushSub?.cancel());
    Future.microtask(load);
    return const NotificationsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await ref.read(getNotificationsUseCaseProvider).call(
            type: state.filter.apiType,
          );
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        unreadCount: page.unreadCount,
      );

      _bindPushStream();

      // Ensure the simulator is running (provider is kept alive by the read).
      ref.read(mockNotificationSimulatorProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final page = await ref.read(getNotificationsUseCaseProvider).call(
            type: state.filter.apiType,
          );
      state = state.copyWith(
        isRefreshing: false,
        items: page.items,
        unreadCount: page.unreadCount,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void setFilter(NotificationFilter filter) {
    if (state.filter == filter) return;
    state = state.copyWith(filter: filter);
    load();
  }

  Future<void> markAsRead(String notificationId) async {
    await ref.read(markNotificationReadUseCaseProvider).call(notificationId);
    state = state.copyWith(
      items: state.items
          .map((n) => n.id == notificationId
              ? n.copyWith(isRead: true, readAt: DateTime.now())
              : n)
          .toList(),
      unreadCount: (state.unreadCount - 1).clamp(0, 999),
    );
  }

  Future<void> markAllAsRead() async {
    await ref.read(markAllNotificationsReadUseCaseProvider).call();
    state = state.copyWith(
      items: state.items
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList(),
      unreadCount: 0,
    );
  }

  void _bindPushStream() {
    _pushSub?.cancel();
    final store = ref.read(mockNotificationStoreProvider);
    _pushSub = store.onNewNotification.listen((_) => refresh());
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);
