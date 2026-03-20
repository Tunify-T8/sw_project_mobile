import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/repository/mock_social_graph_repository_impl.dart';
import 'package:software_project/features/followers_and_social_graph/data/services/mock_social_graph_service.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

void main() {
  group('social graph repository providers', () {
    test('mockSocialGraphServiceProvider returns MockSocialGraphService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(mockSocialGraphServiceProvider);

      expect(service, isA<MockSocialGraphService>());
    });

    test('socialGraphRepositoryProvider returns a SocialGraphRepository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repository = container.read(socialGraphRepositoryProvider);

      expect(repository, isA<SocialGraphRepository>());
    });

    test(
      'socialGraphRepositoryProvider specifically returns MockSocialGraphRepositoryImpl',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final repository = container.read(socialGraphRepositoryProvider);

        expect(repository, isA<MockSocialGraphRepositoryImpl>());
      },
    );

    test('repository instance is built using the service provider dependency', () {
      final customService = TestMockSocialGraphService();
      final container = ProviderContainer(
        overrides: [
          mockSocialGraphServiceProvider.overrideWithValue(customService),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(socialGraphRepositoryProvider);

      expect(repository, isA<MockSocialGraphRepositoryImpl>());
      expect(
        (repository as MockSocialGraphRepositoryImpl).service,
        same(customService),
      );
    });
  });
}

class TestMockSocialGraphService extends MockSocialGraphService {}
