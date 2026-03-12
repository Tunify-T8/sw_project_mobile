import 'package:dio/dio.dart';
import '../../domain/entities/track_metadata.dart';

class FinalizeTrackMetadataRequestDto {
  final String trackId;
  final String title;
  final String genreCategory;
  final String genreSubGenre;
  final List<String> tags;
  final String description;
  final String privacy;
  final String? artworkPath;

  FinalizeTrackMetadataRequestDto({
    required this.trackId,
    required this.title,
    required this.genreCategory,
    required this.genreSubGenre,
    required this.tags,
    required this.description,
    required this.privacy,
    this.artworkPath,
  });

  factory FinalizeTrackMetadataRequestDto.fromEntity({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return FinalizeTrackMetadataRequestDto(
      trackId: trackId,
      title: metadata.title,
      genreCategory: metadata.genreCategory,
      genreSubGenre: metadata.genreSubGenre,
      tags: metadata.tags,
      description: metadata.description,
      privacy: metadata.privacy,
      artworkPath: metadata.artworkPath,
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'trackId': trackId,
      'title': title,
      'genre[category]': genreCategory,
      'genre[subGenre]': genreSubGenre,
      'tags': tags,
      'description': description,
      'privacy': privacy,
      if (artworkPath != null && artworkPath!.isNotEmpty)
        'artwork': await MultipartFile.fromFile(artworkPath!),
    });
  }
}