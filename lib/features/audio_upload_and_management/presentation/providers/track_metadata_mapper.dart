// Upload Feature Guide:
// Purpose: Maps TrackMetadataState into the TrackMetadata domain entity expected by repositories.
// Used by: track_metadata_provider
// Concerns: Metadata engine.
import '../../domain/entities/track_metadata.dart';
import 'track_metadata_state.dart';

class TrackMetadataMapper {
  const TrackMetadataMapper._();

  static TrackMetadata toEntity(TrackMetadataState state) {
    return TrackMetadata(
      title: state.title.trim(),
      genreCategory: state.genreCategory.trim(),
      genreSubGenre: state.genreSubGenre.trim(),
      tags: _parseTags(state.tagsText),
      description: state.description.trim(),
      privacy: state.privacy,
      artists: state.artists
          .map((artist) => artist.trim())
          .where((artist) => artist.isNotEmpty)
          .toList(),
      artworkPath: state.artworkPath,
      recordLabel: state.recordLabel.trim(),
      publisher: state.publisher.trim(),
      isrc: state.isrc.trim(),
      pLine: state.pLine.trim(),
      contentWarning: state.contentWarning,
      scheduledReleaseDate: state.hasScheduledRelease
          ? state.scheduledReleaseDate
          : null,
      allowDownloads: state.allowDownloads,
      offlineListening: state.offlineListening,
      includeInRss: state.includeInRss,
      displayEmbedCode: state.displayEmbedCode,
      appPlaybackEnabled: state.appPlaybackEnabled,
      availabilityType: state.availabilityType,
      availabilityRegions: _parseAvailabilityRegions(state),
      licensing: state.licensing,
    );
  }

  static List<String> _parseTags(String rawTags) {
    return rawTags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  static List<String> _parseAvailabilityRegions(TrackMetadataState state) {
    if (state.availabilityType == 'worldwide') {
      return <String>[];
    }

    return state.availabilityRegionsText
        .split(',')
        .map((region) => region.trim().toUpperCase())
        .where((region) => region.isNotEmpty)
        .toList();
  }
}
