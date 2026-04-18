import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../domain/entities/track_preview_entity.dart';
import '../providers/feed_preview_playback_controller.dart';

Future<void> playFeedTrack(
  BuildContext context,
  WidgetRef ref,
  TrackPreviewEntity track,
) async {
  // Stop any in-flight preview so we don't get overlapping audio when the
  // user jumps straight from the preview overlay to the full-track tile.
  await ref.read(feedPreviewPlaybackControllerProvider).stop();

  if (!context.mounted) return;
  final item = _trackPreviewToUploadItem(track);
  await openUploadItemPlayer(context, ref, item);
}

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
