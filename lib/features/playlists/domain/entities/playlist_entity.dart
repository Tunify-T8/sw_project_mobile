import 'collection_type.dart';
import 'collection_privacy.dart';
import 'playlist_owner_entity.dart';

/// Represents a fully loaded Collection returned by:
///   GET /collections/:id
///   GET /collections/token/:token
///   POST /collections (201)
///   PUT  /collections/:id (200)
class PlaylistEntity {
  final String id;
  final String title;
  final String? description;
  final CollectionType type;
  final CollectionPrivacy privacy;

  /// Only present when [privacy] is [CollectionPrivacy.private].
  final String? secretToken;

  final String? coverUrl;
  final int trackCount;
  final int likeCount;

  /// Number of times this collection has been reposted.
  final int repostsCount;

  /// Follower count of the collection's owner at response time.
  final int ownerFollowerCount;

  /// True when the authenticated user has liked this collection.
  final bool isLiked;

  final PlaylistOwnerEntity? owner;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistEntity({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.privacy,
    this.secretToken,
    this.coverUrl,
    required this.trackCount,
    required this.likeCount,
    required this.repostsCount,
    required this.ownerFollowerCount,
    required this.isLiked,
    this.owner,
    required this.createdAt,
    required this.updatedAt,
  });

  PlaylistEntity copyWith({
    String? id,
    String? title,
    String? description,
    CollectionType? type,
    CollectionPrivacy? privacy,
    String? secretToken,
    String? coverUrl,
    int? trackCount,
    int? likeCount,
    int? repostsCount,
    int? ownerFollowerCount,
    bool? isLiked,
    PlaylistOwnerEntity? owner,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      secretToken: secretToken ?? this.secretToken,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      likeCount: likeCount ?? this.likeCount,
      repostsCount: repostsCount ?? this.repostsCount,
      ownerFollowerCount: ownerFollowerCount ?? this.ownerFollowerCount,
      isLiked: isLiked ?? this.isLiked,
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
