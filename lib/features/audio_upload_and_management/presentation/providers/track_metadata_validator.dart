// Upload Feature Guide:
// Purpose: Validation rules that decide whether metadata can be saved or which message the UI should show.
// Used by: track_metadata_provider
// Concerns: Metadata engine.
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
