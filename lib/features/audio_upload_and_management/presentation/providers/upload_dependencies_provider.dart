import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/file_picker_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/api/upload_api.dart';

// Later, this exact provider can be replaced to read from:

// auth provider

// profile provider

final currentUploadUserIdProvider = Provider<String>((ref) {
  return 'user-demo-id';
});

final currentArtistNameProvider = Provider<String>((ref) {
  return 'ROZANA AHMED';
});

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});

final uploadApiProvider = Provider<UploadApi>((ref) {
  final dio = ref.read(dioProvider);
  return UploadApi(dio);
});