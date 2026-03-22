import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import 'upload_backend_mode_provider.dart';

final libraryUploadsUseMockProvider = Provider<bool>((ref) {
  return ref.watch(uploadBackendModeProvider) != UploadBackendMode.real;
});

final libraryUploadsDioProvider = Provider<Dio>((ref) {
  return ref.watch(dioProvider);
});
