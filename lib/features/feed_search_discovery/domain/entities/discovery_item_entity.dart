import '../entities/resource_type.dart';
import '../entities/track_preview_entity.dart';
import '../entities/collection_entity.dart';
import '../entities/user_preview_entity.dart';

class DiscoveryItemEntity {
  final ResourceType itemType;
  final TrackPreviewEntity? track;
  final CollectionEntity? collection;
  final UserPreviewEntity? user;

  DiscoveryItemEntity({
    required this.itemType,
    this.track,
    this.collection,
    this.user,
  });

  DiscoveryItemEntity copyWith({
    ResourceType? itemType,
    TrackPreviewEntity? track,
    CollectionEntity? collection,
    UserPreviewEntity? user,
  }) {
    return DiscoveryItemEntity(
      itemType: itemType ?? this.itemType,
      track: track ?? this.track,
      collection: collection ?? this.collection,
      user: user ?? this.user,
    );
  }
}
