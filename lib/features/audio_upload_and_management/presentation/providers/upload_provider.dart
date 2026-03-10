import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mock_upload_service.dart';
import '../../domain/entities/upload_state.dart';

final mockUploadServiceProvider = Provider<MockUploadService>((ref) {
  return MockUploadService();
});

class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() {
    return const UploadState();
  }

  Future<void> loadQuota() async {
    state = state.copyWith(
      isLoadingQuota: true,
      error: null,
    );
    
    try {
      final service = ref.read(mockUploadServiceProvider);
      final data = await service.getUploadQuota();

      state = state.copyWith(
        isLoadingQuota: false,
        tier: data['tier'] as String,
        uploadMinutesRemaining: data['uploadMinutesRemaining'] as int,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuota: false,
        error: e.toString(),
      );
    }
  }

  void selectFakeFile() {
    state = state.copyWith(
      selectedFileName: 'my_song.mp3',
      error: null,
    );
  }

  Future<void> createAndUploadTrack() async {
    if (state.selectedFileName == null) {
      state = state.copyWith(error: 'Please select a file first');
      return;
    }

    try {
      final service = ref.read(mockUploadServiceProvider);

      final track = await service.createTrack();

      state = state.copyWith(
        trackId: track['trackId'] as String,
        status: track['status'] as String,
        progress: 0.0,
        error: null,
      );
/// prepare to upload missing
      state = state.copyWith(status: 'uploading');

      await for (final value in service.uploadFileProgress()) {
        state = state.copyWith(progress: value);
      }
/// prepare to process missing
      state = state.copyWith(status: 'processing');
      final finalStatus = await service.processTrack();

      state = state.copyWith(
        status: finalStatus,
        progress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: 'failed',
        error: e.toString(),
      );
    }
  }
}

final uploadProvider =
    NotifierProvider<UploadNotifier, UploadState>(UploadNotifier.new);