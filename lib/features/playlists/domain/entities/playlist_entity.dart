import 'collection_type.dart';
import 'collection_privacy.dart';
import 'playlist_owner_entity.dart';

/// Represents a fully loaded Collection (Playlist or Album) from the backend.
///
/// Used in detail screens, create/edit flows, and the playlist notifier.
/// For lightweight list views, [PlaylistSummaryEntity] is preferred.
class PlaylistEntity {
  final String id;
  final String title;
  final String? description;
  final CollectionType type;
  final CollectionPrivacy privacy;

  /// Only present when [privacy] is [CollectionPrivacy.private].
  /// Share this token to let non-owners access the collection.
  final String? secretToken;

  final String? coverUrl;
  final int trackCount;
  final int likeCount;
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
      owner: owner ?? this.owner,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
