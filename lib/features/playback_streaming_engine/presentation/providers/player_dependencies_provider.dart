import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/api/streaming_api.dart';
import '../../data/services/mock_player_service.dart';

/// Singleton mock service — keeps in-memory state alive for the app session.
final mockPlayerServiceProvider = Provider<MockPlayerService>((ref) {
  return MockPlayerService();
});

/// The real [StreamingApi] wired to the shared authenticated [Dio] instance.
final streamingApiProvider = Provider<StreamingApi>((ref) {
  final dio = ref.read(dioProvider);
  return StreamingApi(dio);
});
