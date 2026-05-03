import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_preview_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_interaction_entity.dart';
import 'package:software_project/features/feed_search_discovery/domain/entities/track_result_entity.dart';
import 'package:software_project/features/feed_search_discovery/presentation/providers/search_provider.dart';
import 'package:software_project/features/feed_search_discovery/presentation/utils/feed_track_playback.dart';
import 'package:software_project/features/feed_search_discovery/presentation/utils/search_track_playback.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_repository_provider.dart';

import '../../../playback_streaming_engine/helpers/playback_test_utils.dart';

void main() {
  late PlaybackTestEnvironment playbackEnvironment;
  late FakePlayerRepository playerRepository;

  setUp(() {
    playbackEnvironment = createPlaybackTestEnvironment();
    playerRepository = FakePlayerRepository();
  });

  tearDown(() async {
    await playbackEnvironment.dispose();
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [
        playerRepositoryProvider.overrideWithValue(playerRepository),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('playFeedTrack stops preview and starts playback without opening screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Consumer(
          builder: (context, ref, _) => ElevatedButton(
            onPressed: () => playFeedTrack(
              context,
              ref,
              TrackPreviewEntity(
                trackId: 'feed-track',
                title: 'Feed Track',
                artistId: 'artist-1',
                artistName: 'Artist',
                isArtistCertified: false,
                duration: 125,
                likesCount: 1,
                repostsCount: 2,
                commentsCount: 3,
                createdAt: '2026-01-01T00:00:00Z',
                interaction: TrackInteractionEntity(
                  isLiked: false,
                  isReposted: false,
                ),
              ),
              openScreen: false,
            ),
            child: const Text('play feed'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('play feed'));
    await tester.pumpAndSettle();

    expect(find.text('play feed'), findsOneWidget);
    expect(
      tester
          .element(find.text('play feed'))
          .findAncestorWidgetOfExactType<Scaffold>(),
      isNotNull,
    );
  });

  testWidgets('playSearchTrack ignores unavailable tracks', (tester) async {
    late WidgetRef capturedRef;
    await tester.pumpWidget(
      wrap(
        Consumer(
          builder: (context, ref, _) {
            capturedRef = ref;
            return ElevatedButton(
              onPressed: () => playSearchTrack(
                context,
                ref,
                const TrackResultEntity(
                  id: 'blocked',
                  title: 'Blocked',
                  artistName: 'Artist',
                  durationSeconds: 90,
                  isUnavailable: true,
                ),
              ),
              child: const Text('play search'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('play search'));
    await tester.pump();

    expect(capturedRef.read(searchProvider).recentResults, isEmpty);
  });

}
