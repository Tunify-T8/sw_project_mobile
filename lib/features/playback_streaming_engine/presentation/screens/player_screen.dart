import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/colors.dart';
import '../../domain/entities/playback_status.dart';
import '../providers/player_provider.dart';
import '../widgets/blocked_track_view.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_waveform_bar.dart';
import 'queue_screen.dart';
import '../../../engagements_social_interactions/presentation/provider/enagement_providers.dart';
import '../../../engagements_social_interactions/presentation/screens/comments_screen.dart';
import '../../../engagements_social_interactions/presentation/screens/likers_screen.dart'; // engagement addition

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
      final trackId = playerState?.bundle?.trackId;
      if (trackId != null) {
        ref.read(engagementProvider(trackId).notifier).loadEngagement(); // engagement addition — load engagement for the initial track on screen open
      }
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

      // engagement addition — reload engagement when user skips to a different track
      final prevTrackId = prev?.asData?.value.bundle?.trackId;
      final nextTrackId = next.asData?.value.bundle?.trackId;
      if (nextTrackId != null && nextTrackId != prevTrackId) {
        ref.read(engagementProvider(nextTrackId).notifier).loadEngagement();
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
              onToggleMore: () => setState(() => _showMore = !_showMore),
            );
          },
        ),
      ),
    );
  }
}
