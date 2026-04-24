import 'collection_type.dart';
import 'collection_privacy.dart';

/// Lightweight collection item used in list responses:
///   - GET /collections/me
///   - GET /users/:username/collections|albums|playlists
///
/// Does NOT include owner or secretToken — use [PlaylistEntity] for those.
class PlaylistSummaryEntity {
  final String id;
  final String title;
  final String? description;
  final CollectionType type;
  final CollectionPrivacy privacy;
  final String? coverUrl;
  final int trackCount;
  final int likeCount;
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
    required this.createdAt,
    required this.updatedAt,
  });
}
