import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../domain/entities/track_result_entity.dart';

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

  await openUploadItemPlayer(
    context,
    ref,
    selected,
    queueItems: queue,
  );
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
