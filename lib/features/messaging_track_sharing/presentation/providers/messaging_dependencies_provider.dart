import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/api/messaging_api.dart';
import '../../data/services/messaging_socket.dart';
import '../../data/services/mock_messaging_socket.dart';
import '../../data/services/mock_messaging_store.dart';
import '../../data/services/real_messaging_socket.dart';
import 'messaging_backend_mode_provider.dart';

/// Messaging should use the same authenticated Dio instance as the rest of
/// the app, so switching Module 9 from mock to real only needs the build-time
/// mode flag and backend availability.
final messagingDioProvider = Provider<Dio>((ref) {
  return ref.watch(dioProvider);
});

final messagingApiProvider = Provider<MessagingApi>(
  (ref) => MessagingApi(ref.watch(messagingDioProvider)),
);

final messagingSessionUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).asData?.value?.id;
});

/// Shared mock store — kept alive for the app lifetime so multiple screens
/// observe the same in-memory dataset.
final mockMessagingStoreProvider = Provider<MockMessagingStore>(
  (ref) => MockMessagingStore(),
);

/// Mock socket is kept exposed separately so the mock repo can type-cast it
/// safely and emit events directly.
final mockMessagingSocketProvider = Provider<MockMessagingSocket>((ref) {
  ref.watch(messagingSessionUserIdProvider);
  final socket = MockMessagingSocket();
  ref.onDispose(socket.dispose);
  return socket;
});

/// The active messaging socket implementation — real Socket.IO in real mode
/// and a lightweight in-memory bus in mock mode.
final messagingSocketProvider = Provider<MessagingSocket>((ref) {
  final mode = ref.watch(messagingBackendModeProvider);
  ref.watch(messagingSessionUserIdProvider);
  if (mode == MessagingBackendMode.real) {
    final socket = RealMessagingSocket(const TokenStorage());
    ref.onDispose(socket.dispose);
    return socket;
  }
  return ref.watch(mockMessagingSocketProvider);
});
