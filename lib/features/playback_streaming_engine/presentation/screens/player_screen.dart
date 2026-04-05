import 'dart:ui';

import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/playback_status.dart';
import '../providers/player_provider.dart';
import '../widgets/blocked_track_view.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_waveform_bar.dart';
import 'queue_screen.dart';

part 'player_screen_body.dart';
part 'player_screen_visuals.dart';
part 'player_screen_details.dart';
part 'player_screen_actions.dart';
part 'player_screen_sheet.dart';
part 'player_screen_states.dart';

/// Full-screen player â€” pushed on top of the app when a track is loaded.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _artworkController;
  late Animation<double> _artworkScale;
  bool _showMore = false;

  /// Direction of the most recent track-navigation swipe.
  /// 1 = next (swiped left), -1 = previous (swiped right), 0 = none.
  /// Passed to _PlayerBody so AnimatedSwitcher can slide in from the correct side.
  int _swipeDir = 0;

  @override
  void initState() {
    super.initState();
    _artworkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _artworkScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _artworkController, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerState = ref.read(playerProvider).asData?.value;
      if (playerState?.isPlaying == true) _artworkController.forward();
    });
  }

  @override
  void dispose() {
    _artworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);

    ref.listen<AsyncValue<PlayerState>>(playerProvider, (prev, next) {
      final wasPlaying = prev?.asData?.value.isPlaying ?? false;
      final isPlaying = next.asData?.value.isPlaying ?? false;
      if (isPlaying && !wasPlaying) {
        _artworkController.forward();
      } else if (!isPlaying && wasPlaying) {
        _artworkController.reverse();
      }

      // Reset swipe direction once the track actually changes so that
      // subsequent rebuilds don't keep applying the slide offset.
      final prevId = prev?.asData?.value.bundle?.trackId;
      final nextId = next.asData?.value.bundle?.trackId;
      if (prevId != null && nextId != null && prevId != nextId) {
        // Use addPostFrameCallback so the AnimatedSwitcher picks up _swipeDir
        // during the current frame before we clear it.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _swipeDir = 0);
        });
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: playerAsync.when(
          loading: () => const _PlayerLoading(),
          error: (error, _) => _PlayerError(error: error.toString()),
          data: (playerState) {
            if (playerState.bundle == null) return const _PlayerEmpty();

            final bundle = playerState.bundle!;
            if (bundle.playability.isBlocked) {
              return _BlockedWithNav(
                blockedReason: bundle.playability.blockedReason,
              );
            }

            return _PlayerBody(
              playerState: playerState,
              artworkScale: _artworkScale,
              showMore: _showMore,
              swipeDir: _swipeDir,
              onToggleMore: () => setState(() => _showMore = !_showMore),
              onSwipeNext: () => setState(() => _swipeDir = 1),
              onSwipePrevious: () => setState(() => _swipeDir = -1),
            );
          },
        ),
      ),
    );
  }
}
