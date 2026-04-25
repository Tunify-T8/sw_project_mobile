import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/push_notification_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_providers.dart';
import 'notification_filter.dart';

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
  }) => NotificationsState(
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    items: items ?? this.items,
    error: clearError ? null : (error ?? this.error),
    filter: filter ?? this.filter,
    unreadCount: unreadCount ?? this.unreadCount,
  );
}

class NotificationsController extends Notifier<NotificationsState> {
  StreamSubscription<NotificationEntity>? _realtimeSub;

  @override
  NotificationsState build() {
    ref.onDispose(_cleanup);
    Future.microtask(load);
    return const NotificationsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(notificationRepositoryProvider);

      // Connect realtime socket (idempotent).
      await repo.connectRealtime();

      // Bind the realtime stream — new server-pushed notifications arrive here.
      _bindRealtimeStream();

      // In mock mode also start the simulator.
      final mode = ref.read(notificationBackendModeProvider);
      if (mode == NotificationBackendMode.mock) {
        ref.read(mockNotificationSimulatorProvider);
      }

      final page = await ref
          .read(getNotificationsUseCaseProvider)
          .call(type: state.filter.apiType);
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        unreadCount: page.unreadCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final page = await ref
          .read(getNotificationsUseCaseProvider)
          .call(type: state.filter.apiType);
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
    final wasUnread = state.items.any(
      (n) => n.id == notificationId && !n.isRead,
    );

    await ref.read(markNotificationReadUseCaseProvider).call(notificationId);
    state = state.copyWith(
      items: state.items
          .map(
            (n) => n.id == notificationId
                ? n.copyWith(isRead: true, readAt: DateTime.now())
                : n,
          )
          .toList(),
      unreadCount: wasUnread ? (state.unreadCount - 1).clamp(0, 999) : null,
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

  // ── Realtime ──────────────────────────────────────────────────────────────

  void _bindRealtimeStream() {
    _realtimeSub?.cancel();
    _realtimeSub = ref
        .read(notificationRepositoryProvider)
        .realtimeNotifications()
        .listen(_onRealtimeNotification);
  }

  void _onRealtimeNotification(NotificationEntity notification) {
    final withoutDuplicate = state.items
        .where((n) => n.id != notification.id)
        .toList();
    final wasAlreadyUnread = state.items.any(
      (n) => n.id == notification.id && !n.isRead,
    );
    final shouldCountAsUnread = !notification.isRead && !wasAlreadyUnread;

    // Prepend to list and bump unread counter only for new unread items.
    state = state.copyWith(
      items: [notification, ...withoutDuplicate],
      unreadCount: shouldCountAsUnread
          ? state.unreadCount + 1
          : state.unreadCount,
    );

    // Fire device-level push so it appears in the system notification tray.
    PushNotificationService.instance.show(
      id: notification.id.hashCode,
      title: notification.actor?.username ?? 'Tunify',
      body: notification.message,
      payload: notification.id,
    );
  }

  void _cleanup() {
    _realtimeSub?.cancel();
    _realtimeSub = null;
    // Disconnect socket on controller dispose.
    ref.read(notificationRepositoryProvider).disconnectRealtime();
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
