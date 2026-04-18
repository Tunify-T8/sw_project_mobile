import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/api/messaging_api.dart';
import '../../data/services/messaging_socket.dart';
import '../../data/services/mock_messaging_socket.dart';
import '../../data/services/mock_messaging_store.dart';

/// Messaging should use the same authenticated Dio instance as the rest of the
/// app, so switching Module 9 from mock to real only needs the build-time mode
/// flag and backend availability.
final messagingDioProvider = Provider<Dio>((ref) {
  return ref.watch(dioProvider);
});

final messagingApiProvider = Provider<MessagingApi>(
  (ref) => MessagingApi(ref.watch(messagingDioProvider)),
);

/// Shared mock store — kept alive for the app lifetime so multiple screens
/// observe the same in-memory dataset.
final mockMessagingStoreProvider =
    Provider<MockMessagingStore>((ref) => MockMessagingStore());

/// Default socket is the mock one. Once the backend websocket contract is
/// finalized, this provider can be swapped to a real socket transport without
/// touching the rest of the messaging feature.
final messagingSocketProvider = Provider<MessagingSocket>((ref) {
  final socket = MockMessagingSocket();
  ref.onDispose(socket.dispose);
  return socket;
});
