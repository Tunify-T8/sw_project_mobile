// Upload Feature Guide:
// Purpose: Supplies the low-level dependencies and mock toggle used by the uploads-library providers.
// Used by: library_uploads_repository_provider
// Concerns: Multi-format support; Track visibility.
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
