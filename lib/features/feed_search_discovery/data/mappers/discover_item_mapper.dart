import 'collection_mapper.dart';
import 'track_preview_mapper.dart';
import 'user_preview_mapper.dart';
import '../dto/discovery_item_dto.dart';
import '../../domain/entities/discovery_item_entity.dart';

extension DiscoverItemMapper on DiscoveryItemDto {
  DiscoveryItemEntity toEntity() {
    return DiscoveryItemEntity(
      itemType: itemType,
      track: track?.toEntity(),
      collection: collection?.toEntity(),
      user: user?.toEntity(),
    );
  }
}
