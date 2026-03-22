// Upload Feature Guide:
// Purpose: Builds the upload repository graph and switches between mock, Cloudinary, and real backend modes.
// Used by: track_metadata_provider, upload_provider, track_metadata_screen
// Concerns: Multi-format support.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/cloudinary_upload_repository_impl.dart';
import '../../data/services/cloudinary_upload_config.dart';
import '../../data/repository/mock_upload_repository_impl.dart';
import '../../data/repository/real_upload_repository_impl.dart';
import '../../data/services/cloudinary_media_service.dart';
import '../../data/services/mock_upload_service.dart';
import '../../domain/repositories/upload_repository.dart';
import 'upload_backend_mode_provider.dart';
import 'upload_dependencies_provider.dart';

//explain :
final mockUploadServiceProvider = Provider<MockUploadService>((ref) {
  return MockUploadService();
});
//why does cloudinary need two providers? one for dio and one for the media service?
//
final cloudinaryDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );
});

final cloudinaryMediaServiceProvider = Provider<CloudinaryMediaService>((ref) {
  return CloudinaryMediaService(
    dio: ref.read(cloudinaryDioProvider),
    cloudName: CloudinaryUploadConfig.cloudName,
    audioUploadPreset: CloudinaryUploadConfig.audioUploadPreset,
    imageUploadPreset: CloudinaryUploadConfig.imageUploadPreset,
    apiKey: CloudinaryUploadConfig.apiKey,
    apiSecret: CloudinaryUploadConfig.apiSecret,
  );
});

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final mode = ref.watch(uploadBackendModeProvider);

  if (mode == UploadBackendMode.real) {
    return RealUploadRepository(ref.watch(uploadApiProvider));
  }

  if (mode == UploadBackendMode.cloudinary) {
    return CloudinaryUploadRepository(
      ref.watch(cloudinaryMediaServiceProvider),
    );
  }

  return MockUploadRepository(service: ref.watch(mockUploadServiceProvider));
});
