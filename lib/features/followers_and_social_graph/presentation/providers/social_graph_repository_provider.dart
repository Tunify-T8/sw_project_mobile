import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/social_graph_repository.dart';
import '../../data/repository/mock_social_graph_repository_impl.dart';
import '../../data/services/mock_social_graph_service.dart';

final mockSocialGraphServiceProvider = Provider<MockSocialGraphService>((ref) {
  return MockSocialGraphService();
});

final socialGraphRepositoryProvider = Provider<SocialGraphRepository>((ref) {
  final service = ref.read(mockSocialGraphServiceProvider);
  return MockSocialGraphRepositoryImpl(service: service);
});