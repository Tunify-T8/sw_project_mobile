import '../../domain/entities/collection_entity.dart';
import '../dto/collection_dto.dart';

extension CollectionMapper on CollectionDto {
  CollectionEntity toEntity() {
    return CollectionEntity(
      id: id,
      type: type,
      title: title,
      creatorId: creatorId,
      creatorName: creatorName,
      coverUrl: coverUrl,
      trackCount: trackCount,
      duration: duration,
      releaseYear: releaseYear,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}