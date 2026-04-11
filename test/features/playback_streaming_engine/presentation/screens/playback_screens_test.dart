import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/history_track.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/listening_history_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/screens/player_screen.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/screens/queue_screen.dart';

import '../../helpers/playback_test_utils.dart';
import '../../../../test_utils/mock_network_images.dart';

void main() {
  late PlaybackTestEnvironment environment;
  late TestPlayerNotifier playerNotifier;
  late TestListeningHistoryNotifier historyNotifier;

  Widget buildApp(Widget child) {
    return ProviderScope(
      overrides: [
        playerProvider.overrideWith(() => playerNotifier),
        listeningHistoryProvider.overrideWith(() => historyNotifier),
      ],
      child: MaterialApp(home: child),
    );
  }

  setUp(() {
    environment = createPlaybackTestEnvironment();
    playerNotifier = TestPlayerNotifier(const PlayerState());
    historyNotifier = TestListeningHistoryNotifier(
      const ListeningHistoryState(),
    );
  });

  tearDown(() async {
    await environment.dispose();
  });

  group('PlayerScreen', () {
    testWidgets('renders loading, error, empty, and blocked states', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(const PlayerScreen()));
      playerNotifier.emitAsync(const AsyncLoading<PlayerState>());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      playerNotifier.emitAsync(
        AsyncError<PlayerState>('boom', StackTrace.empty),
      );
      await tester.pump();
      expect(find.text('boom'), findsOneWidget);

      playerNotifier.emit(const PlayerState());
      await tester.pump();
      expect(find.text('No track loaded'), findsOneWidget);

      playerNotifier.emit(
        samplePlayerState(
          bundle: sampleBundle(
            status: PlaybackStatus.blocked,
            blockedReason: BlockedReason.tierRestricted,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Pro Subscription Required'), findsOneWidget);
    });

    testWidgets(
      'renders full player content, more sheet, and queue navigation',
      (tester) async {
        playerNotifier.currentState = samplePlayerState(
          bundle: sampleBundle(
            coverUrl: 'https://example.com/cover.png',
            waveformUrl: 'https://example.com/waveform.json',
          ),
          queue: sampleQueue(),
          isPlaying: true,
          positionSeconds: 12,
          volume: 0.6,
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(buildApp(const PlayerScreen()));
          await tester.pumpAndSettle();

          expect(find.text('Night Drive'), findsOneWidget);
          expect(find.text('DJ Test'), findsOneWidget);
          expect(find.text('Share'), findsOneWidget);
          expect(find.text('Queue'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.queue_music));
          await tester.pumpAndSettle();
          expect(find.text('Next up'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.close));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.more_vert));
          await tester.pumpAndSettle();
          expect(find.text('Report'), findsOneWidget);
        });
      },
    );
  });

  group('QueueScreen', () {
    testWidgets('shows empty queue fallback', (tester) async {
      playerNotifier.currentState = samplePlayerState(
        bundle: sampleBundle(),
        queue: null,
      );

      await tester.pumpWidget(buildApp(const QueueScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Queue is empty'), findsOneWidget);
    });

    testWidgets('shows queue rows and handles track selection', (tester) async {
      playerNotifier.currentState = samplePlayerState(
        bundle: sampleBundle(coverUrl: 'https://example.com/cover.png'),
        queue: sampleQueue(currentIndex: 0),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildApp(const QueueScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Now Playing'), findsOneWidget);
        expect(find.text('Track track-2'), findsOneWidget);

        await playerNotifier.jumpToQueueIndex(1);
        await tester.pump();

        expect(playerNotifier.jumpCalls, 1);
      });
    });
  });

  group('ListeningHistoryScreen', () {
    testWidgets('shows loading, error, and empty states', (tester) async {
      await tester.pumpWidget(buildApp(const ListeningHistoryScreen()));

      historyNotifier.emitAsync(const AsyncLoading<ListeningHistoryState>());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      historyNotifier.emitAsync(
        AsyncError<ListeningHistoryState>('history failed', StackTrace.empty),
      );
      await tester.pump();
      expect(find.text('Failed to load history'), findsOneWidget);

      historyNotifier.emit(
        const ListeningHistoryState(tracks: <HistoryTrack>[]),
      );
      await tester.pump();
      expect(find.text('No listening history'), findsOneWidget);
    });

    testWidgets('renders data list, clear dialog, and scroll-based load more', (
      tester,
    ) async {
      playerNotifier.currentState = const PlayerState();
      historyNotifier.currentState = ListeningHistoryState(
        tracks: List<HistoryTrack>.generate(
          12,
          (index) => sampleHistoryTrack(
            trackId: 'track-${index + 1}',
            coverUrl: index == 0 ? 'https://example.com/cover.png' : null,
          ),
        ),
        currentPage: 1,
        hasMore: true,
        isLoadingMore: true,
        isRefreshing: true,
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildApp(const ListeningHistoryScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('Listening history'), findsOneWidget);
        expect(find.text('Night Drive'), findsWidgets);

        historyNotifier.emit(
          ListeningHistoryState(
            tracks: <HistoryTrack>[
              sampleHistoryTrack(trackId: 'track-2'),
              sampleHistoryTrack(
                trackId: 'track-1',
                coverUrl: 'https://example.com/cover.png',
              ),
              ...List<HistoryTrack>.generate(
                10,
                (index) => sampleHistoryTrack(trackId: 'track-${index + 3}'),
              ),
            ],
            currentPage: 1,
            hasMore: true,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 450));

        await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(historyNotifier.loadMoreCalls, greaterThanOrEqualTo(1));

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.text('Clear listening history?'), findsOneWidget);

        await tester.tap(find.text('Clear'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(historyNotifier.clearCalls, 1);
      });
    });
  });
}
