// Upload Feature Guide:
// Purpose: Factory helpers for building initial metadata state for new uploads and edit mode.
// Used by: track_metadata_provider
// Concerns: Metadata engine.
import '../../domain/entities/upload_item.dart';
import 'track_metadata_state.dart';

TrackMetadataState buildNewUploadTrackMetadataState({
  required String fileName,
  required String primaryArtist,
}) {
  return TrackMetadataState(title: fileName, artists: [primaryArtist]);
}

TrackMetadataState buildEditTrackMetadataState({
  required UploadItem item,
  required String primaryArtist,
}) {
  final artists = item.artistDisplay
      .split(', ')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList();

  return TrackMetadataState(
    title: item.title,
    genreCategory: item.genreCategory,
    genreSubGenre: item.genreSubGenre,
    tagsText: item.tags.join(', '),
    description: item.description ?? '',
    privacy: item.visibility == UploadVisibility.public ? 'public' : 'private',
    artists: artists.isEmpty ? [primaryArtist] : artists,
    artworkPath: item.localArtworkPath ?? item.artworkUrl,
    recordLabel: item.recordLabel,
    publisher: item.publisher,
    isrc: item.isrc,
    pLine: item.pLine,
    hasScheduledRelease: item.scheduledReleaseDate != null,
    scheduledReleaseDate: item.scheduledReleaseDate,
    contentWarning: item.isExplicit,
    allowDownloads: true,
    offlineListening: item.offlineListening,
    includeInRss: item.includeInRss,
    displayEmbedCode: item.displayEmbedCode,
    appPlaybackEnabled: item.appPlaybackEnabled,
    availabilityType: item.availabilityType,
    availabilityRegionsText: item.availabilityRegions.join(', '),
    licensing: item.licensing,
  );
}
