import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/api/upload_api.dart';
import '../../data/services/file_picker_service.dart';

final currentUploadUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.asData?.value;
  return user?.id ?? '';
});

final currentArtistNameProvider = Provider<String>((ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.asData?.value;
  return user?.username ?? 'Authenticated artist';
});

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});

final uploadApiProvider = Provider<UploadApi>((ref) {
  final dio = ref.read(dioProvider);
  return UploadApi(dio);
});