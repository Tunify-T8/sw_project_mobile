import '../../domain/entities/collection_type.dart';

class CollectionDto {
  final String id;
  final CollectionType type;
  final String title;
  final String creatorId;
  final int trackCount;
  final String createdAt;

  CollectionDto({
    required this.id,
    required this.type,
    required this.title,
    required this.creatorId,
    required this.trackCount,
    required this.createdAt,
  });

  factory CollectionDto.fromJson(Map<String, dynamic> json) {
    return CollectionDto(
      id: json['id']?.toString() ?? '',
      type: CollectionType.values.byName(json['type']),
      title: json['title']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      trackCount: json['trackCount'] ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}