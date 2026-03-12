import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/mock_upload_repository_impl.dart';
import '../../data/repository/real_upload_repository_impl.dart';
import '../../data/services/mock_upload_service.dart';
import '../../domain/repositories/upload_repository.dart';
import 'upload_backend_mode_provider.dart';
import 'upload_dependencies_provider.dart';

final mockUploadServiceProvider = Provider<MockUploadService>((ref) {
  return MockUploadService();
});

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final mode = ref.read(uploadBackendModeProvider);

  if (mode == UploadBackendMode.real) {
    return RealUploadRepository(
      ref.read(uploadApiProvider),
    );
  }

  return MockUploadRepository(
    service: ref.read(mockUploadServiceProvider),
  );
});