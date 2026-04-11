import 'trending_track_entity.dart';

class TrendingGenreEntity {
  final String genre;
  final List<TrendingTrackEntity> tracks;

  TrendingGenreEntity({required this.genre, required this.tracks});

  TrendingGenreEntity copyWith({
    String? genre,
    List<TrendingTrackEntity>? tracks,
  }) {
    return TrendingGenreEntity(
      genre: genre ?? this.genre,
      tracks: tracks ?? this.tracks,
    );
  }
}
