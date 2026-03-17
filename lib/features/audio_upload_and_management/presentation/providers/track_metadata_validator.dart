import 'track_metadata_state.dart';

class TrackMetadataValidator {
  const TrackMetadataValidator._();

  static String? validateForSave(TrackMetadataState state) {
    if (state.title.trim().isEmpty) {
      return 'Title is required.';
    }

    final hasAtLeastOneArtist = state.artists.any(
      (artist) => artist.trim().isNotEmpty,
    );

    if (!hasAtLeastOneArtist) {
      return 'At least one artist is required.';
    }

    return null;
  }
}
