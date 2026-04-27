import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/api/subscription_api.dart';
import '../../data/repository/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository> ((ref){
  final api = SubscriptionApi(ref.read(dioProvider));
  return SubscriptionRepositoryImpl(api);
});
