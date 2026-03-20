import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';

final libraryUploadsUseMockProvider = Provider<bool>((ref) {
  return true;
});

final libraryUploadsDioProvider = Provider<Dio>((ref) {
  return ref.watch(dioProvider);
});
