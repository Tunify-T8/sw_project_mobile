import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/api/notification_api.dart';
import '../../data/repository/mock_notification_repository_impl.dart';
import '../../data/repository/real_notification_repository_impl.dart';
import '../../data/services/mock_notification_socket.dart';
import '../../data/services/mock_notification_simulator.dart';
import '../../data/services/mock_notification_store.dart';
import '../../data/services/notification_socket.dart';
import '../../data/services/real_notification_socket.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notification_preferences_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/update_notification_preferences_usecase.dart';

// ─── Backend mode ────────────────────────────────────────────────────────────
// Switch to NotificationBackendMode.mock for offline development.
enum NotificationBackendMode { mock, real }

const NotificationBackendMode _activeBackend = NotificationBackendMode.real;

final notificationBackendModeProvider =
    Provider<NotificationBackendMode>((ref) => _activeBackend);

// ─── Infrastructure ──────────────────────────────────────────────────────────

final notificationDioProvider = Provider<Dio>((ref) => ref.watch(dioProvider));

final notificationApiProvider = Provider<NotificationApi>(
  (ref) => NotificationApi(ref.watch(notificationDioProvider)),
);

final notificationSocketProvider = Provider<NotificationSocket>((ref) {
  final mode = ref.watch(notificationBackendModeProvider);
  if (mode == NotificationBackendMode.real) {
    final socket = RealNotificationSocket(const TokenStorage());
    ref.onDispose(socket.dispose);
    return socket;
  }
  final socket = MockNotificationSocket();
  ref.onDispose(socket.dispose);
  return socket;
});

// Mock-only infrastructure (kept alive only when mode == mock).
final mockNotificationStoreProvider = Provider<MockNotificationStore>((ref) {
  final store = MockNotificationStore();
  ref.onDispose(store.dispose);
  return store;
});

final mockNotificationSimulatorProvider =
    Provider<MockNotificationSimulator>((ref) {
  final mode = ref.watch(notificationBackendModeProvider);
  final store = ref.watch(mockNotificationStoreProvider);
  final simulator = MockNotificationSimulator(store);
  if (mode == NotificationBackendMode.mock) simulator.start();
  ref.onDispose(simulator.stop);
  return simulator;
});

// ─── Repository ──────────────────────────────────────────────────────────────

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  final mode = ref.watch(notificationBackendModeProvider);

  if (mode == NotificationBackendMode.real) {
    return RealNotificationRepository(
      ref.watch(notificationApiProvider),
      ref.watch(notificationSocketProvider),
    );
  }

  return MockNotificationRepository(ref.watch(mockNotificationStoreProvider));
});

// ─── Use Cases ───────────────────────────────────────────────────────────────

final getNotificationsUseCaseProvider = Provider(
    (ref) => GetNotificationsUseCase(ref.watch(notificationRepositoryProvider)));

final getUnreadCountUseCaseProvider = Provider(
    (ref) => GetUnreadCountUseCase(ref.watch(notificationRepositoryProvider)));

final markNotificationReadUseCaseProvider = Provider((ref) =>
    MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider)));

final markAllNotificationsReadUseCaseProvider = Provider((ref) =>
    MarkAllNotificationsReadUseCase(ref.watch(notificationRepositoryProvider)));

final getNotificationPreferencesUseCaseProvider = Provider((ref) =>
    GetNotificationPreferencesUseCase(
        ref.watch(notificationRepositoryProvider)));

final updateNotificationPreferencesUseCaseProvider = Provider((ref) =>
    UpdateNotificationPreferencesUseCase(
        ref.watch(notificationRepositoryProvider)));
