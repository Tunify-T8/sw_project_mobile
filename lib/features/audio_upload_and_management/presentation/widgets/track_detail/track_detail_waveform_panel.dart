import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/design_system/colors.dart';
import '../../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_waveform_provider.dart';
import 'track_detail_soundcloud_waveform.dart';

part 'track_detail_waveform_panel_playing.dart';
part 'track_detail_waveform_panel_actions.dart';

class TrackDetailWaveformPanel extends ConsumerWidget {
  const TrackDetailWaveformPanel({
    super.key,
    required this.item,
    required this.state,
    required this.onMoreTap,
    required this.onPlayPauseTap,
    required this.onSeekFraction,
  });

  final UploadItem item;
  final TrackDetailWaveformState state;
  final VoidCallback onMoreTap;
  final VoidCallback onPlayPauseTap;
  final ValueChanged<double> onSeekFraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waveformBarsAsync = ref.watch(trackDetailWaveformBarsProvider(item));
    final bars = item.waveformBars ?? waveformBarsAsync.asData?.value;
    final description = item.description?.trim() ?? '';
    final playerState = ref.watch(playerProvider).asData?.value;
    final isCurrentTrack = playerState?.bundle?.trackId == item.id;
    final isPlaying = isCurrentTrack && playerState?.isPlaying == true;
    final durationSeconds = isCurrentTrack
        ? (playerState?.effectiveDurationSeconds ?? item.durationSeconds)
        : item.durationSeconds;
    final progress = isCurrentTrack && durationSeconds > 0
        ? ((playerState?.positionSeconds ?? 0) / durationSeconds)
              .clamp(0.0, 1.0)
              .toDouble()
        : 0.0;

    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (description.isNotEmpty && isPlaying) ...[
                Align(
                  alignment: Alignment.center,
                  child: _WaveformCommentBubble(text: description),
                ),
                const SizedBox(height: 14),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: isPlaying
                    ? _PlayingWaveform(
                        key: const ValueKey('playing'),
                        item: item,
                        state: state,
                        bars: bars,
                        isLoading:
                            item.waveformBars == null &&
                            waveformBarsAsync.isLoading,
                        progress: progress,
                        onSeekFraction: onSeekFraction,
                      )
                    : _PausedSurface(
                        key: const ValueKey('paused'),
                        item: item,
                        progress: progress,
                        durationSeconds: durationSeconds,
                        onPlayPauseTap: onPlayPauseTap,
                        onSeekFraction: onSeekFraction,
                      ),
              ),
              const SizedBox(height: 16),
              const _CommentComposerBar(),
              const SizedBox(height: 16),
              _BottomActionBar(onMoreTap: onMoreTap),
            ],
          ),
        ),
      ),
    );
  }
}
