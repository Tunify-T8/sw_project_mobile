import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../domain/entities/track_result_entity.dart';
import '../providers/search_provider.dart';

/// Plays a [TrackResultEntity] from any search or genre-detail surface.
///
/// FIX (M8-019 — Recently Played only when track actually plays):
/// After [openUploadItemPlayer] returns, [recordTrackPlayed] is called on
/// the [searchProvider] notifier. This is the ONLY place a track enters
/// the "Recently Played" row. The old [_autoRecordTopResult] approach
/// (which added items on every search query) has been removed from
/// search_provider.dart.
///
/// [queueTracks] — optional list used to build the playback queue so the
/// player can advance to the next track automatically.
Future<void> playSearchTrack(
  BuildContext context,
  WidgetRef ref,
  TrackResultEntity track, {
  List<TrackResultEntity>? queueTracks,
}) async {
  if (track.isUnavailable) return;

  final selected = _trackToUploadItem(track);
  final queue = queueTracks
      ?.where((t) => !t.isUnavailable)
      .map(_trackToUploadItem)
      .toList(growable: false);

  await openUploadItemPlayer(context, ref, selected, queueItems: queue);

  // Record as recently played now that playback has been initiated.
  // Guard with context.mounted because openUploadItemPlayer may push a route.
  if (context.mounted) {
    ref.read(searchProvider.notifier).recordTrackPlayed(track);
  }
}

UploadItem _trackToUploadItem(TrackResultEntity t) {
  return UploadItem(
    id: t.id,
    title: t.title,
    artistDisplay: t.artistName,
    durationLabel: _formatDuration(t.durationSeconds),
    durationSeconds: t.durationSeconds,
    artworkUrl: t.artworkUrl,
    visibility: UploadVisibility.public,
    status: UploadProcessingStatus.finished,
    isExplicit: false,
    createdAt: DateTime.now(),
  );
}

String _formatDuration(int totalSeconds) {
  final safe = totalSeconds < 0 ? 0 : totalSeconds;
  final m = safe ~/ 60;
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
