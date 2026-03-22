// Upload Feature Guide:
// Purpose: Maps Cloudinary draft/workflow data into UploadedTrack and UploadItem shapes used by the rest of the feature.
// Used by: cloudinary_upload_artwork_resolver, cloudinary_upload_workflow
// Concerns: Multi-format support.
import '../../domain/entities/upload_item.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../services/global_track_store.dart';
import 'cloudinary_pending_track.dart';

UploadedTrack mapPendingTrackToUploadedTrack(
  PendingCloudinaryTrack draft,
  UploadStatus status,
) {
  return UploadedTrack(
    trackId: draft.trackId,
    status: status,
    audioUrl: draft.audioUrl,
    waveformUrl: draft.waveformUrl,
    title: draft.title,
    description: draft.description,
    privacy: draft.privacy,
    artworkUrl: draft.artworkUrl,
    durationSeconds: draft.durationSeconds,
  );
}

void savePendingTrackToGlobalStore(
  PendingCloudinaryTrack draft, {
  required UploadProcessingStatus status,
}) {
  final ownerUserId = draft.ownerUserId?.trim();

  GlobalTrackStore.instance.add(
    UploadItem(
      id: draft.trackId,
      title: draft.title?.trim().isNotEmpty == true
          ? draft.title!.trim()
          : 'Untitled',
      artistDisplay: draft.artists.isEmpty
          ? 'Authenticated artist'
          : draft.artists.join(', '),
      durationLabel: formatCloudinaryDuration(draft.durationSeconds),
      durationSeconds: draft.durationSeconds,
      audioUrl: draft.audioUrl,
      waveformUrl: draft.waveformUrl,
      waveformBars: draft.waveformBars,
      artworkUrl: draft.artworkUrl,
      localArtworkPath: draft.localArtworkPath,
      localFilePath: draft.localFilePath,
      description: draft.description,
      tags: draft.tags,
      genreCategory: draft.genreCategory,
      genreSubGenre: draft.genreSubGenre,
      visibility: draft.privacy == 'public'
          ? UploadVisibility.public
          : UploadVisibility.private,
      status: status,
      isExplicit: draft.contentWarning,
      recordLabel: draft.recordLabel,
      publisher: draft.publisher,
      isrc: draft.isrc,
      pLine: draft.pLine,
      scheduledReleaseDate: draft.scheduledReleaseDate,
      allowDownloads: draft.allowDownloads,
      offlineListening: draft.offlineListening,
      includeInRss: draft.includeInRss,
      displayEmbedCode: draft.displayEmbedCode,
      appPlaybackEnabled: draft.appPlaybackEnabled,
      availabilityType: draft.availabilityType,
      availabilityRegions: draft.availabilityRegions,
      licensing: draft.licensing,
      createdAt: draft.createdAt,
    ),
    ownerUserId: ownerUserId == null || ownerUserId.isEmpty
        ? '__global__'
        : ownerUserId,
  );
}

UploadStatus mapUploadProcessingStatus(UploadProcessingStatus status) {
  switch (status) {
    case UploadProcessingStatus.processing:
      return UploadStatus.processing;
    case UploadProcessingStatus.finished:
      return UploadStatus.finished;
    case UploadProcessingStatus.failed:
      return UploadStatus.failed;
    case UploadProcessingStatus.deleted:
      return UploadStatus.deleted;
  }
}

bool isRemoteCloudinaryAsset(String value) {
  return value.startsWith('http://') || value.startsWith('https://');
}

String cloudinaryFileNameFromPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final parts = normalized.split('/');
  return parts.isEmpty ? path : parts.last;
}

String formatCloudinaryDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
