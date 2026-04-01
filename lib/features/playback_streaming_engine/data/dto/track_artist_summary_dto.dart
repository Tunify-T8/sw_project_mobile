class TrackArtistSummaryDto {
  const TrackArtistSummaryDto({
    required this.id,
    required this.name,
    this.tier,
    this.username,
    this.displayName,
    this.avatarUrl,
  });

  final String id;

  /// Canonical display name your UI will use.
  final String name;

  /// Old contract field. Keep optional for backward compatibility.
  final String? tier;

  /// Newer backend fields.
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  factory TrackArtistSummaryDto.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] as String?)?.trim();
    final rawUsername = (json['username'] as String?)?.trim();
    final rawDisplayName = (json['displayName'] as String?)?.trim();

    final resolvedName = (rawDisplayName != null && rawDisplayName.isNotEmpty)
        ? rawDisplayName
        : (rawName != null && rawName.isNotEmpty)
            ? rawName
            : (rawUsername != null && rawUsername.isNotEmpty)
                ? rawUsername
                : 'Unknown artist';

    return TrackArtistSummaryDto(
      id: (json['id'] ?? '') as String,
      name: resolvedName,
      tier: json['tier'] as String?,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}