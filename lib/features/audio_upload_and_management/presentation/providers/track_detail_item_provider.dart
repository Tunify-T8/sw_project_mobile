import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/upload_item.dart';
import '../../domain/entities/uploaded_track.dart';
import 'upload_repository_provider.dart';

final trackDetailItemProvider =
    FutureProvider.autoDispose.family<UploadItem, UploadItem>((ref, item) async {
  try {
    final repository = ref.read(uploadRepositoryProvider);
    final details = await repository.getTrackDetails(item.id);
    return mergeTrackDetailItem(base: item, details: details);
  } catch (_) {
    return item;
  }
});

UploadItem mergeTrackDetailItem({
  required UploadItem base,
  required UploadedTrack details,
}) {
  final mergedArtists = details.artists
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(', ');

  final mergedDurationSeconds = details.durationSeconds ?? base.durationSeconds;

  return base.copyWith(
    title: _resolveText(details.title, fallback: base.title),
    artistDisplay: mergedArtists.isEmpty ? base.artistDisplay : mergedArtists,
    durationSeconds: mergedDurationSeconds,
    durationLabel: mergedDurationSeconds > 0
        ? _formatDuration(mergedDurationSeconds)
        : base.durationLabel,
    audioUrl: _resolveOptionalText(details.audioUrl, fallback: base.audioUrl),
    waveformUrl: _resolveOptionalText(
      details.waveformUrl,
      fallback: base.waveformUrl,
    ),
    artworkUrl: _resolveOptionalText(
      details.artworkUrl,
      fallback: base.artworkUrl,
    ),
    description: _resolveOptionalText(
      details.description,
      fallback: base.description,
    ),
    visibility: _resolveVisibility(details.privacy, fallback: base.visibility),
  );
}

String _resolveText(String? value, {required String fallback}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}

String? _resolveOptionalText(String? value, {String? fallback}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}

UploadVisibility _resolveVisibility(
  String? privacy, {
  required UploadVisibility fallback,
}) {
  switch (privacy) {
    case 'public':
      return UploadVisibility.public;
    case 'private':
      return UploadVisibility.private;
    default:
      return fallback;
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
