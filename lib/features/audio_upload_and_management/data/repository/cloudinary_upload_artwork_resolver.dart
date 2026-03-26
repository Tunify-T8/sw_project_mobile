// Upload Feature Guide:
// Purpose: Decides whether artwork should be kept, replaced, or uploaded during Cloudinary metadata saves.
// Used by: cloudinary_upload_workflow
// Concerns: Multi-format support; Metadata engine.
import '../../domain/entities/track_metadata.dart';
import '../services/cloudinary_media_service.dart';
import 'cloudinary_pending_track.dart';
import 'cloudinary_upload_mapper.dart';

typedef CloudinaryArtworkResolution = ({
  String? artworkUrl,
  String? localArtworkPath,
});

Future<CloudinaryArtworkResolution> resolveCloudinaryArtwork({
  required CloudinaryMediaService mediaService,
  required String? artworkPath,
  required String? currentArtworkUrl,
  required String? currentLocalArtworkPath,
}) async {
  final trimmedPath = artworkPath?.trim();
  if (trimmedPath == null || trimmedPath.isEmpty) {
    return (
      artworkUrl: currentArtworkUrl,
      localArtworkPath: currentLocalArtworkPath,
    );
  }
  if (isRemoteCloudinaryAsset(trimmedPath)) {
    return (artworkUrl: trimmedPath, localArtworkPath: currentLocalArtworkPath);
  }

  final uploadedArtwork = await mediaService.uploadArtwork(
    filePath: trimmedPath,
    fileName: cloudinaryFileNameFromPath(trimmedPath),
  );
  return (artworkUrl: uploadedArtwork.secureUrl, localArtworkPath: trimmedPath);
}

PendingCloudinaryTrack applyCloudinaryTrackMetadata(
  PendingCloudinaryTrack current,
  TrackMetadata metadata,
  CloudinaryArtworkResolution artwork,
) {
  return current.copyWith(
    title: metadata.title,
    description: metadata.description,
    privacy: metadata.privacy,
    artists: metadata.artists,
    tags: metadata.tags,
    genreCategory: metadata.genreCategory,
    genreSubGenre: metadata.genreSubGenre,
    recordLabel: metadata.recordLabel,
    publisher: metadata.publisher,
    isrc: metadata.isrc,
    pLine: metadata.pLine,
    contentWarning: metadata.contentWarning,
    scheduledReleaseDate: metadata.scheduledReleaseDate,
    allowDownloads: metadata.allowDownloads,
    offlineListening: metadata.offlineListening,
    includeInRss: metadata.includeInRss,
    displayEmbedCode: metadata.displayEmbedCode,
    appPlaybackEnabled: metadata.appPlaybackEnabled,
    availabilityType: metadata.availabilityType,
    availabilityRegions: metadata.availabilityRegions,
    licensing: metadata.licensing,
    artworkUrl: artwork.artworkUrl,
    localArtworkPath: artwork.localArtworkPath,
  );
}
