import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/cloudinary_upload_repository_impl.dart';
import '../../data/repository/mock_upload_repository_impl.dart';
import '../../data/repository/real_upload_repository_impl.dart';
import '../../data/services/cloudinary_media_service.dart';
import '../../data/services/mock_upload_service.dart';
import '../../domain/repositories/upload_repository.dart';
import 'upload_backend_mode_provider.dart';
import 'upload_dependencies_provider.dart';

final mockUploadServiceProvider = Provider<MockUploadService>((ref) {
  return MockUploadService();
});

final cloudinaryDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );
});

final cloudinaryMediaServiceProvider = Provider<CloudinaryMediaService>((ref) {
  return CloudinaryMediaService(
    dio: ref.read(cloudinaryDioProvider),
    cloudName: const String.fromEnvironment('CLOUDINARY_CLOUD_NAME'),
    audioUploadPreset: const String.fromEnvironment('CLOUDINARY_AUDIO_UPLOAD_PRESET'),
    imageUploadPreset: const String.fromEnvironment('CLOUDINARY_IMAGE_UPLOAD_PRESET'),
  );
});

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final mode = ref.read(uploadBackendModeProvider);

  if (mode == UploadBackendMode.real) {
    return RealUploadRepository(
      ref.read(uploadApiProvider),
    );
  }

  if (mode == UploadBackendMode.cloudinary) {
    return CloudinaryUploadRepository(
      ref.read(cloudinaryMediaServiceProvider),
    );
  }

  return MockUploadRepository(
    service: ref.read(mockUploadServiceProvider),
  );
});
