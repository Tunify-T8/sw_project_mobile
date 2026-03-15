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
    );
  }

  static List<String> _parseTags(String rawTags) {
    return rawTags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}