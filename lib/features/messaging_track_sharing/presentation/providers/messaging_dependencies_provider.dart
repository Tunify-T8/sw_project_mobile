import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/messaging_api.dart';
import '../../data/services/messaging_socket.dart';
import '../../data/services/mock_messaging_socket.dart';
import '../../data/services/mock_messaging_store.dart';

/// Wire the Dio instance used for messaging — override in main.dart
/// with the app-wide authenticated Dio.
final messagingDioProvider = Provider<Dio>((ref) {
  throw UnimplementedError(
    'messagingDioProvider must be overridden with an authenticated Dio',
  );
});

final messagingApiProvider = Provider<MessagingApi>(
  (ref) => MessagingApi(ref.watch(messagingDioProvider)),
);

/// Shared mock store — kept alive for the app lifetime so multiple screens
/// observe the same in-memory dataset.
final mockMessagingStoreProvider =
    Provider<MockMessagingStore>((ref) => MockMessagingStore());

/// Default socket is the mock one. The real impl (ws / socket.io) should
/// override this provider in the composition root once implemented.
final messagingSocketProvider = Provider<MessagingSocket>((ref) {
  final socket = MockMessagingSocket();
  ref.onDispose(socket.dispose);
  return socket;
});
