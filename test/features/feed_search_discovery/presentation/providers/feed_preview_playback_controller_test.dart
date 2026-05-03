import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/feed_preview_playback_controller.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/stream_url.dart';
import 'package:software_project/features/playback_streaming_engine/domain/repositories/player_repository.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_repository_provider.dart';

import '../../../playback_streaming_engine/helpers/playback_test_utils.dart';

class FakePlayerRepository implements PlayerRepository {
  var requestedTrackIds = <String>[];

  @override
  Future<StreamUrl> requestStreamUrl(
    String trackId, {
    String quality = 'auto',
    String? privateToken,
  }) async {
    requestedTrackIds.add(trackId);
    return StreamUrl(
      trackId: trackId,
      url: 'https://example.com/$trackId.mp3',
      expiresInSeconds: 60,
      format: 'mp3',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late PlaybackTestEnvironment playbackEnvironment;

  setUp(() {
    playbackEnvironment = createPlaybackTestEnvironment();
  });

  tearDown(() async {
    await playbackEnvironment.dispose();
  });

  test('state notifier updates and resets preview state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      feedPreviewPlaybackStateProvider.notifier,
    );

    notifier.update(
      const FeedPreviewPlaybackState(
        trackId: 'track-1',
        progress: 0.5,
        isPlaying: true,
      ),
    );

    expect(container.read(feedPreviewPlaybackStateProvider).trackId, 'track-1');
    expect(container.read(feedPreviewPlaybackStateProvider).progress, 0.5);
    expect(container.read(feedPreviewPlaybackStateProvider).isPlaying, isTrue);

    notifier.reset();
    expect(container.read(feedPreviewPlaybackStateProvider).trackId, isNull);
    expect(container.read(feedPreviewPlaybackStateProvider).progress, 0);
    expect(container.read(feedPreviewPlaybackStateProvider).isPlaying, isFalse);
  });

  test('controller requests stream, tolerates audio setup failure, and stops', () async {
    final repository = FakePlayerRepository();
    final container = ProviderContainer(
      overrides: [
        playerRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(feedPreviewPlaybackControllerProvider);

    await controller.start('track-1', 75);
    expect(repository.requestedTrackIds, ['track-1']);

    await controller.stop();
    expect(container.read(feedPreviewPlaybackStateProvider).trackId, isNull);

    await controller.dispose();
    await controller.start('track-2', 10);
    expect(repository.requestedTrackIds, ['track-1']);
  });
}
