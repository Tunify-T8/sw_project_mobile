import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/global_track_store.dart';
import '../../domain/entities/upload_item.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import 'upload_repository_provider.dart';

final trackDetailItemProvider = FutureProvider.autoDispose
    .family<UploadItem, UploadItem>((ref, item) async {
      try {
        final repository = ref.read(uploadRepositoryProvider);
        final details = await repository.getTrackDetails(item.id);
        final merged = mergeTrackDetailItem(base: item, details: details);
        ref.read(globalTrackStoreProvider).update(merged);
        return merged;
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
    tags: details.tags ?? base.tags,
    genreCategory: _resolveEditableText(
      details.genreCategory,
      fallback: base.genreCategory,
    ),
    genreSubGenre: _resolveEditableText(
      details.genreSubGenre,
      fallback: base.genreSubGenre,
    ),
    visibility: _resolveVisibility(details.privacy, fallback: base.visibility),
    status: _resolveProcessingStatus(details.status, fallback: base.status),
    isExplicit: details.contentWarning ?? base.isExplicit,
    recordLabel: _resolveEditableText(
      details.recordLabel,
      fallback: base.recordLabel,
    ),
    publisher: _resolveEditableText(
      details.publisher,
      fallback: base.publisher,
    ),
    isrc: _resolveEditableText(details.isrc, fallback: base.isrc),
    pLine: _resolveEditableText(details.pLine, fallback: base.pLine),
    scheduledReleaseDate:
        details.scheduledReleaseDate ?? base.scheduledReleaseDate,
    allowDownloads: details.allowDownloads ?? base.allowDownloads,
    offlineListening: details.offlineListening ?? base.offlineListening,
    includeInRss: details.includeInRss ?? base.includeInRss,
    displayEmbedCode: details.displayEmbedCode ?? base.displayEmbedCode,
    appPlaybackEnabled: details.appPlaybackEnabled ?? base.appPlaybackEnabled,
    availabilityType: _resolveEditableText(
      details.availabilityType,
      fallback: base.availabilityType,
    ),
    availabilityRegions:
        details.availabilityRegions ?? base.availabilityRegions,
    licensing: _resolveEditableText(
      details.licensing,
      fallback: base.licensing,
    ),
    privateToken: _resolveOptionalText(
      details.privateToken,
      fallback: base.privateToken,
    ),
  );
}

UploadProcessingStatus _resolveProcessingStatus(
  UploadStatus status, {
  required UploadProcessingStatus fallback,
}) {
  switch (status) {
    case UploadStatus.finished:
      return UploadProcessingStatus.finished;
    case UploadStatus.processing:
    case UploadStatus.uploading:
    case UploadStatus.idle:
      return UploadProcessingStatus.processing;
    case UploadStatus.failed:
      return UploadProcessingStatus.failed;
    case UploadStatus.deleted:
      return UploadProcessingStatus.deleted;
  }
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

String _resolveEditableText(String? value, {required String fallback}) {
  if (value == null) {
    return fallback;
  }

  return value.trim();
}

UploadVisibility _resolveVisibility(
  String? privacy, {
  required UploadVisibility fallback,
}) {
  switch (privacy?.trim().toLowerCase()) {
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
