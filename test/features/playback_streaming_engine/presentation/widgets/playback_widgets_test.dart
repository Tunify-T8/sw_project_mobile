import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playback_streaming_engine/domain/entities/playback_status.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/providers/player_provider.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/widgets/blocked_track_view.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/widgets/mini_player.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/widgets/player_controls.dart';
import 'package:software_project/features/playback_streaming_engine/presentation/widgets/player_waveform_bar.dart';

import '../../helpers/playback_test_utils.dart';
import '../../../../test_utils/mock_network_images.dart';

void main() {
  late PlaybackTestEnvironment environment;

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  setUp(() {
    environment = createPlaybackTestEnvironment();
  });

  tearDown(() async {
    await environment.dispose();
  });

  group('BlockedTrackView', () {
    testWidgets('shows upgrade CTA for tier restrictions', (tester) async {
      await tester.pumpWidget(
        wrap(
          const BlockedTrackView(blockedReason: BlockedReason.tierRestricted),
        ),
      );

      expect(find.text('Pro Subscription Required'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsOneWidget);
    });

    testWidgets('shows region messaging without upgrade button', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const BlockedTrackView(blockedReason: BlockedReason.regionRestricted),
        ),
      );

      expect(find.text('Not Available in Your Region'), findsOneWidget);
      expect(find.text('Upgrade to Pro'), findsNothing);
    });
  });

  testWidgets('MiniPlayer hides when no track is loaded', (tester) async {
    final notifier = TestPlayerNotifier(const PlayerState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerProvider.overrideWith(() => notifier)],
        child: wrap(const MiniPlayer()),
      ),
    );

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.text('Night Drive'), findsNothing);
  });

  testWidgets('MiniPlayer renders playback info and reflects play state', (
    tester,
  ) async {
    final notifier = TestPlayerNotifier(
      samplePlayerState(
        bundle: sampleBundle(isLiked: true),
        isPlaying: false,
        positionSeconds: 50,
        mediaDurationSeconds: 100,
      ),
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [playerProvider.overrideWith(() => notifier)],
          child: wrap(const MiniPlayer()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Night Drive'), findsOneWidget);
      expect(find.text('DJ Test'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      notifier.emit(notifier.currentState.copyWith(isPlaying: true));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  testWidgets('PlayerControls dispatches transport actions', (tester) async {
    var playCalls = 0;
    var pauseCalls = 0;
    var nextCalls = 0;
    var previousCalls = 0;
    var shuffleCalls = 0;
    var repeatCalls = 0;

    await tester.pumpWidget(
      wrap(
        PlayerControls(
          isPlaying: false,
          hasQueue: true,
          isShuffle: true,
          repeatMode: 1,
          onPlay: () => playCalls++,
          onPause: () => pauseCalls++,
          onNext: () => nextCalls++,
          onPrevious: () => previousCalls++,
          onShuffle: () => shuffleCalls++,
          onRepeat: () => repeatCalls++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.tap(find.byIcon(Icons.repeat_one));
    await tester.pumpAndSettle();

    expect(playCalls, 1);
    expect(previousCalls, 1);
    expect(nextCalls, 1);
    expect(shuffleCalls, 1);
    expect(repeatCalls, 1);

    await tester.pumpWidget(
      wrap(
        PlayerControls(
          isPlaying: true,
          hasQueue: false,
          onPlay: () => playCalls++,
          onPause: () => pauseCalls++,
          onNext: () => nextCalls++,
          onPrevious: () => previousCalls++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump(const Duration(milliseconds: 120));

    expect(pauseCalls, 1);
  });

  group('PlayerWaveformBar', () {
    testWidgets('maps taps to normal track seek positions', (tester) async {
      final seeks = <int>[];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  child: PlayerWaveformBar(
                    waveformUrl: '',
                    positionSeconds: 10,
                    durationSeconds: 100,
                    onSeek: seeks.add,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(tester.getCenter(find.byType(PlayerWaveformBar)));
      await tester.pump();

      expect(seeks.single, closeTo(50, 2));
    });

    testWidgets('maps drags within preview window', (tester) async {
      final seeks = <int>[];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 200,
                  child: PlayerWaveformBar(
                    waveformUrl: '',
                    positionSeconds: 34.9,
                    durationSeconds: 100,
                    isPreviewOnly: true,
                    previewStartSeconds: 10,
                    previewDurationSeconds: 30,
                    onSeek: seeks.add,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(PlayerWaveformBar), const Offset(30, 0));
      await tester.pump();

      expect(seeks, isNotEmpty);
      expect(seeks.last, inInclusiveRange(29, 31));
    });
  });
}
