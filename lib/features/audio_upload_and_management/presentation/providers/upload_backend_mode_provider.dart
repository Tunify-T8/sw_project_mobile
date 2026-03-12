import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UploadBackendMode {
  mock,
  real,
}

final uploadBackendModeProvider = Provider<UploadBackendMode>((ref) {
  return UploadBackendMode.mock;
});