import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mock_trending_service.dart';
import '../../data/repository/mock_trending_repository_impl.dart';
import '../../domain/repositories/trending_repository.dart';

final trendingServiceProvider = Provider<MockTrendingService>((ref) {
  return MockTrendingService();
});

final trendingRepositoryProvider = Provider<TrendingRepository>((ref) {
  final service = ref.read(trendingServiceProvider);
  return MockTrendingRepositoryImpl(service);
});