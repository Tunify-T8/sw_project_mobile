import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/api/discovery_api.dart';
import '../../data/repository/discovery_repository_impl.dart';
import '../../domain/repositories/discovery_repository.dart';

final feedRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  final api = DiscoveryApi(ref.read(dioProvider));
  return DiscoveryRepositoryImpl(api);
});