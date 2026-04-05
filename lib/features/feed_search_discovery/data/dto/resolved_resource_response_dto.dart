import 'track_preview_dto.dart';
import 'collection_dto.dart';
import 'user_preview_dto.dart';
import '../../domain/entities/resource_type.dart';

class ResolvedResourceResponseDto {
  final ResourceType resourceType;
  final TrackPreviewDto? track;
  final CollectionDto? collection;
  final UserPreviewDto? user;

  ResolvedResourceResponseDto({
    required this.resourceType,
    this.track,
    this.collection, 
    this.user
  });

   factory ResolvedResourceResponseDto.fromJson(Map<String, dynamic> json){
    final type = ResourceType.values.byName(json['resourceType']);
    return ResolvedResourceResponseDto(
      resourceType: type,
      track: type == ResourceType.track
          ? TrackPreviewDto.fromJson(json['resource'])
          : null,
      collection: type == ResourceType.collection
          ? CollectionDto.fromJson(json['resource'])
          : null,
      user: type == ResourceType.user
          ? UserPreviewDto.fromJson(json['resource'])
          : null,
    );
  }
}
