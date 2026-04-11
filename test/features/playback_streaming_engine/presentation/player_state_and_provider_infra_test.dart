import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/features/playback_streaming_engine/data/api/streaming_api.dart';
import 'package:software_project/features/playback_streaming_engine/data/repository/mock_player_repository_impl.dart';
import 'package:software_project/features/playback_streaming_engine/data/repository/real_player_repository_impl.dart';
import 'package:software_project/features/playback_streaming_engine/data/services/mock_player_service.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_backend_mode_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_dependencies_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_repository_provider.dart';

import '../helpers/playback_test_utils.dart';
import '../../audio_upload_and_management/helpers/local_upload_test_mocks.dart';

void main() {
  group('PlayerState', () {
    test('derives playback metrics for regular tracks', () {
      final state = samplePlayerState(
        bundle: sampleBundle(durationSeconds: 200),
        positionSeconds: 50,
        mediaDurationSeconds: 220,
      );

      expect(state.hasTrack, isTrue);
      expect(state.canPlay, isTrue);
      expect(state.isPreviewOnly, isFalse);
      expect(state.previewStartSeconds, 0);
      expect(state.previewEndSeconds, 200);
      expect(state.effectiveDurationSeconds, 200);
      expect(state.effectivePositionSeconds, 50);
      expect(state.visualDurationSeconds, 220);
      expect(state.normalizedProgress, closeTo(50 / 220, 0.0001));
    });

    test('derives preview-only metrics and near-end completion progress', () {
      final state = samplePlayerState(
        bundle: sampleBundle(
          status: PlaybackStatus.preview,
          previewEnabled: true,
          previewStartSeconds: 5,
          previewDurationSeconds: 30,
          durationSeconds: 180,
        ),
        positionSeconds: 34.9,
      );

      expect(state.isPreviewOnly, isTrue);
      expect(state.previewStartSeconds, 5);
      expect(state.previewEndSeconds, 35);
      expect(state.effectiveDurationSeconds, 30);
      expect(state.effectivePositionSeconds, closeTo(29.9, 0.0001));
      expect(state.visualDurationSeconds, 30);
      expect(state.normalizedProgress, 1.0);
    });

    test('copyWith preserves or clears nullable fields explicitly', () {
      final state = samplePlayerState(
        streamUrl: sampleStreamUrl(),
        queue: sampleQueue(),
        streamExpiresAt: DateTime.utc(2026, 4, 4, 21),
        localFilePath: 'C:/music/file.mp3',
        mediaDurationSeconds: 180,
      );

      final updated = state.copyWith(
        isMuted: true,
        bundle: null,
        streamUrl: null,
        queue: null,
        streamExpiresAt: null,
        localFilePath: null,
        mediaDurationSeconds: null,
      );

      expect(updated.isMuted, isTrue);
      expect(updated.bundle, isNull);
      expect(updated.streamUrl, isNull);
      expect(updated.queue, isNull);
      expect(updated.streamExpiresAt, isNull);
      expect(updated.localFilePath, isNull);
      expect(updated.mediaDurationSeconds, isNull);
    });
  });

  test('playerBackendModeProvider defaults to real', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(playerBackendModeProvider), PlayerBackendMode.real);
  });

  test('player dependency providers expose service and api', () {
    final dio = MockDio();
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(dio),
      ],
    );
    addTearDown(container.dispose);

    final mockService = container.read(mockPlayerServiceProvider);
    final streamingApi = container.read(streamingApiProvider);

    expect(mockService, isA<MockPlayerService>());
    expect(streamingApi, isA<StreamingApi>());
  });

  group('playerRepositoryProvider', () {
    test('returns real repository when mode is real', () {
      final container = ProviderContainer(
        overrides: [
          playerBackendModeProvider.overrideWith((_) => PlayerBackendMode.real),
          dioProvider.overrideWithValue(MockDio()),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(playerRepositoryProvider),
        isA<RealPlayerRepository>(),
      );
    });

    test('returns mock repository when mode is mock', () {
      final container = ProviderContainer(
        overrides: [
          playerBackendModeProvider.overrideWith((_) => PlayerBackendMode.mock),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(playerRepositoryProvider),
        isA<MockPlayerRepository>(),
      );
    });
  });
}
