 
  import 'package:software_project/features/feed_search_discovery/domain/repositories/trending_repository.dart';
import '../services/mock_trending_service.dart';
import '../../domain/entities/trending_genre_entity.dart';

class MockTrendingRepositoryImpl implements TrendingRepository{
  final MockTrendingService mockTrendingService;
  MockTrendingRepositoryImpl(this.mockTrendingService);
  
 @override
  Future<TrendingGenreEntity> getTrending({required String genre}) async {
    return await mockTrendingService.getTrendingByGenre(genre: genre);
  }
}