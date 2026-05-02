import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../domain/entities/track_preview_entity.dart';
import '../providers/feed_preview_playback_controller.dart';

Future<void> playFeedTrack(
  BuildContext context,
  WidgetRef ref,
  TrackPreviewEntity track, {
  bool openScreen = true,
  bool restartIfCurrent = false,
}) async {
  // Stop any in-flight preview so we don't get overlapping audio when the
  // user jumps straight from the preview overlay to the full-track tile.
  await ref.read(feedPreviewPlaybackControllerProvider).stop();

  // Convert the feed track preview model into the UploadItem shape expected by
  // the shared player/detail launcher.
  final stub = _trackPreviewToUploadItem(track);

  final current = ref.read(playerProvider).asData?.value;
  if (restartIfCurrent &&
      current?.bundle?.trackId == track.trackId &&
      current?.isBuffering != true) {
    final notifier = ref.read(playerProvider.notifier);
    await notifier.seek(0);
    await notifier.play();
    return;
  }

  if (!openScreen) {
    await ensureUploadItemPlayback(ref, stub, autoPlay: true);
    return;
  }

  // Feed entities don't carry a waveformUrl, so the stub has no way to fetch
  // bars on its own. The shared launcher only allows 500 ms for pre-resolution
  // — not enough on a cold first play — and when it times out the waveform
  // provider caches NULL against this track id, which means the bars never
  // surface until the screen is closed and reopened.
  //
  // Resolving the enriched item (with waveformUrl + waveformBars embedded)
  // here, WITHOUT a timeout, guarantees the waveform renders on the first
  // frame of TrackDetailScreen. The user explicitly opted into this delay.
  final enrichedItem = await prepareTrackSurfaceItem(ref, stub);

  if (!context.mounted) return;
  await openUploadItemPlayer(context, ref, enrichedItem);
}

// Feed cards only have TrackPreviewEntity data, while the shared playback
// launcher expects an UploadItem. This adapter bridges those two modules.
UploadItem _trackPreviewToUploadItem(TrackPreviewEntity t) {
  return UploadItem(
    id: t.trackId,
    title: t.title,
    artistDisplay: t.artistName,
    durationLabel: _formatDuration(t.duration),
    durationSeconds: t.duration,
    artworkUrl: t.coverUrl,
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    createdAt: DateTime.tryParse(t.createdAt) ?? DateTime.now(),
  );
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final m = safe ~/ 60;
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
