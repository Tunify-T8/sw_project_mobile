import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../providers/track_detail_waveform_provider.dart';

part 'track_detail_soundcloud_waveform_layout.dart';
part 'track_detail_soundcloud_waveform_badge.dart';
part 'track_detail_soundcloud_waveform_painters.dart';

class TrackDetailSoundcloudWaveform extends StatelessWidget {
  const TrackDetailSoundcloudWaveform({
    super.key,
    required this.state,
    required this.isLoading,
    this.bars,
    this.progress = 0.0,
  });

  final TrackDetailWaveformState state;
  final List<double>? bars;
  final bool isLoading;
  final double progress;

  @override
  Widget build(BuildContext context) {
    const totalHeight = 220.0;

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final waveformBars = bars;
          if (waveformBars != null && waveformBars.isNotEmpty) {
            return _DynamicWaveform(
              bars: waveformBars,
              progress: progress,
              duration: state.duration,
              totalHeight: totalHeight,
              containerWidth: constraints.maxWidth,
            );
          }

          return _FallbackWaveform(
            duration: state.duration,
            progress: progress,
            totalHeight: totalHeight,
            containerWidth: constraints.maxWidth,
            useMutedOpacity: isLoading,
          );
        },
      ),
    );
  }
}
