// Upload Feature Guide:
// Purpose: Central backend-mode switch for the upload feature, controlled by the UPLOAD_BACKEND environment value.
// Used by: library_uploads_dependencies_provider, upload_repository_provider
// Concerns: Multi-format support.
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UploadBackendMode { mock, real }

const String _uploadBackendModeValue = String.fromEnvironment(
  'UPLOAD_BACKEND',
  defaultValue: 'real',
);

final uploadBackendModeProvider = Provider<UploadBackendMode>((ref) {
  switch (_uploadBackendModeValue.toLowerCase()) {
    case 'mock':
      return UploadBackendMode.mock;
    case 'real':
    default:
      return UploadBackendMode.real;
  }
});
