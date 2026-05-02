// Domain entities for search autocomplete results.
//
// These are the clean-architecture counterparts of [AutocompleteResponseDto].
// The repository maps DTOs → these entities; use-cases and the provider
// operate exclusively on these types.

class AutocompleteTrackEntity {
  final String id;
  final String title;
  final String artist;

  const AutocompleteTrackEntity({
    required this.id,
    required this.title,
    required this.artist,
  });
}

class AutocompleteUserEntity {
  final String id;
  final String username;

  /// Preferred display name. When non-null/non-empty this is shown in the UI
  /// instead of [username]. (Fixes M8-021 — display name over username.)
  final String? displayName;

  const AutocompleteUserEntity({
    required this.id,
    required this.username,
    this.displayName,
  });

  /// The name that should be shown in suggestion rows and recent-result tiles.
  String get displayLabel => (displayName != null && displayName!.isNotEmpty)
      ? displayName!
      : username;
}

class AutocompleteCollectionEntity {
  final String id;
  final String title;
  final String artist;

  const AutocompleteCollectionEntity({
    required this.id,
    required this.title,
    required this.artist,
  });
}

class AutocompleteResultEntity {
  final List<AutocompleteTrackEntity> tracks;
  final List<AutocompleteUserEntity> users;
  final List<AutocompleteCollectionEntity> collections;

  const AutocompleteResultEntity({
    required this.tracks,
    required this.users,
    required this.collections,
  });
}
