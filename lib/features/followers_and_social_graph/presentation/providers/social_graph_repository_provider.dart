import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/followers_and_social_graph/data/repository/real_social_graph_repository_impl.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/social_graph_repository.dart';
import '../../data/api/social_api.dart';

final socialGraphRepositoryProvider = Provider<SocialGraphRepository>((ref) {
  final api = SocialApi(ref.read(dioProvider));
  return SocialGraphRepositoryImpl(api);
});
