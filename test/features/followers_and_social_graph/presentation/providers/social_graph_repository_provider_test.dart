import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/features/followers_and_social_graph/data/repository/real_social_graph_repository_impl.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

void main() {
  test('socialGraphRepositoryProvider builds the real repository implementation', () {
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(Dio())],
    );
    addTearDown(container.dispose);

    final repository = container.read(socialGraphRepositoryProvider);

    expect(repository, isA<SocialGraphRepository>());
    expect(repository, isA<SocialGraphRepositoryImpl>());
  });
}
