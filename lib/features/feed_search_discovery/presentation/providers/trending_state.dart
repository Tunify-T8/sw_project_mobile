import '../../domain/entities/trending_genre_entity.dart';

class TrendingState {
  final TrendingGenreEntity? trending;
  final bool isLoading;
  final String? error;

  const TrendingState({
    this.trending,
    this.isLoading = false,
    this.error,
  });

  TrendingState copyWith({
    TrendingGenreEntity? trending,
    bool? isLoading,
    String? error,
  }) {
    return TrendingState(
      trending: trending ?? this.trending,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}