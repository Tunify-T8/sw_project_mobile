/// Minimal artist info embedded inside playback responses.
///
/// The backend contract changed a bit during the project:
/// - older drafts used: { id, name, tier }
/// - newer drafts use: { id, username, displayName, avatarUrl }
///
/// To keep the rest of the UI simple, the domain layer exposes one unified
/// `name` field that the presentation layer can render directly.
class TrackArtistSummary {
  const TrackArtistSummary({
    required this.id,
    required this.name,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.tier,
  });

  final String id;

  /// Final displayable name used by the UI.
  final String name;

  /// Optional raw fields preserved for compatibility with different backend
  /// response versions.
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? tier;
}
