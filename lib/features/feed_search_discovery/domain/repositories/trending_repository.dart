import '../entities/trending_genre_entity.dart';

abstract class TrendingRepository {
    Future<TrendingGenreEntity> getTrending({
  required String genre,
});
}