import '../../domain/entities/trending_track_entity.dart';
import '../dto/trending_item_dto.dart';

extension TrendingItemDtoMapper on TrendingItemDto {
  TrendingTrackEntity toEntity() {
    return TrendingTrackEntity(
      trackId: id,
      title: name,
      artistName: artist,
      coverUrl: coverUrl,

      //temporary till back end returns them
      isLiked: false,
      isReposted: false, 
    );
  }
}
