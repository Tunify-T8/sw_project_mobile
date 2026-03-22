import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UploadBackendMode { mock, cloudinary, real }

const String _uploadBackendModeValue = String.fromEnvironment(
  'UPLOAD_BACKEND',
  defaultValue: 'real',
);

final uploadBackendModeProvider = Provider<UploadBackendMode>((ref) {
  switch (_uploadBackendModeValue.toLowerCase()) {
    case 'mock':
      return UploadBackendMode.mock;
    case 'cloudinary':
      return UploadBackendMode.cloudinary;
    case 'real':
    default:
      return UploadBackendMode.real;
  }
});
