import '../../domain/entities/collection_type.dart';

class CollectionDto {
  final String id;
  final CollectionType type;
  final String title;
  final String creatorId;
  final String creatorName;
  final String? coverUrl;
  final int trackCount;
  final int duration;
  final int? releaseYear;
  final String createdAt;

  CollectionDto({
    required this.id,
    required this.type,
    required this.title,
    required this.creatorId,
    required this.creatorName,
    this.coverUrl,
    required this.trackCount,
    required this.duration,
    this.releaseYear,
    required this.createdAt,
  });

  factory CollectionDto.fromJson(Map<String, dynamic> json) {
    return CollectionDto(
      id: json['id']?.toString() ?? '',
      type: CollectionType.values.byName(json['type']),
      title: json['title']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString(),
      trackCount: json['trackCount'] ?? 0,
      duration: json['duration'] ?? 0,
      releaseYear: json['releaseYear'],
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}