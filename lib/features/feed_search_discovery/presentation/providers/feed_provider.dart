import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/feed_search_discovery/domain/repositories/feed_repository.dart';
import '../../data/services/mock_feed_service.dart';
import '../../data/repository/mock_feed_repository_impl.dart';

final feedServiceProvider = Provider<MockFeedService>((ref){
  return MockFeedService();
});

final feedRepositoryProvider = Provider<FeedRepository>((ref){
  final service = ref.read(feedServiceProvider);
  return MockFeedRepositoryImpl(service);
});

