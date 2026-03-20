import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UploadBackendMode { mock, cloudinary, real }

final uploadBackendModeProvider = Provider<UploadBackendMode>((ref) {
  // Keep Cloudinary as a separate mode so the UI/use-cases stay unchanged.
  // Later, when backend is ready, you only switch this provider to `real`.
  return UploadBackendMode.cloudinary;
});
