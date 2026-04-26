import 'collection_type.dart';
import 'collection_privacy.dart';

/// Lightweight collection item used in list responses:
///   GET /collections/me
///   GET /users/:username/collections|albums|playlists
class PlaylistSummaryEntity {
  final String id;
  final String title;
  final String? description;
  final CollectionType type;
  final CollectionPrivacy privacy;
  final String? coverUrl;
  final int trackCount;
  final int likeCount;

  /// Number of times this collection has been reposted.
  final int repostsCount;

  /// Follower count of the owner at response time.
  final int ownerFollowerCount;

  /// True when this collection was created by the authenticated user.
  /// Only present in GET /collections/me responses.
  final bool isMine;

  /// True when the authenticated user has liked this collection.
  /// Only present in GET /collections/me responses.
  final bool isLiked;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistSummaryEntity({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.privacy,
    this.coverUrl,
    required this.trackCount,
    required this.likeCount,
    required this.repostsCount,
    required this.ownerFollowerCount,
    required this.isMine,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });
}
