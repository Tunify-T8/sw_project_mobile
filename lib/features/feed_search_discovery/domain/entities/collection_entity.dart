import 'collection_type.dart';

class CollectionEntity {
  final String id;
  final CollectionType type;
  final String title;
  final String creatorId;
  final String creatorName;
  final String? coverUrl;
  final int trackCount;
  final int duration;
  final int? releaseYear;
  final DateTime createdAt;

  CollectionEntity({
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

  CollectionEntity copyWith({
    String? id,
    CollectionType? type,
    String? title,
    String? creatorId,
    String? creatorName,
    String? coverUrl,
    int? trackCount,
    int? duration,
    int? releaseYear,
    DateTime? createdAt,
  }) {
    return CollectionEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      duration: duration ?? this.duration,
      releaseYear: releaseYear ?? this.releaseYear,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}