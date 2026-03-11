import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/file_picker_service.dart';
import '../../data/services/mock_upload_service.dart';
import '../../domain/entities/upload_state.dart';
import '../../domain/entities/upload_status.dart';

final mockUploadServiceProvider = Provider<MockUploadService>((ref) {
  return MockUploadService();
});

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});

class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() {
    return const UploadState();
  }

  Future<void> loadQuota() async {
    state = state.copyWith(isLoadingQuota: true, error: null);

    try {
      final service = ref.read(mockUploadServiceProvider);
      final data = await service.getUploadQuota();

      state = state.copyWith(
        isLoadingQuota: false,
        tier: data['tier'] as String,
        uploadMinutesRemaining: data['uploadMinutesRemaining'] as int,
      );
    } catch (e) {
      state = state.copyWith(isLoadingQuota: false, error: e.toString());
    }
  }

  Future<void> pickFile() async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final PlatformFile? file = await picker.pickAudioFile();

      if (file == null) {
        return;
      }

      state = state.copyWith(
        selectedFileName: file.name,
        selectedFilePath: file.path,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> createAndUploadTrack() async {
    if (state.selectedFileName == null) {
      state = state.copyWith(error: 'Please select an audio file first');
      return false;
    }

    try {
      final service = ref.read(mockUploadServiceProvider);

      final track = await service.createTrack(
        fileName: state.selectedFileName!,
      );

      state = state.copyWith(
        trackId: track['trackId'] as String,
        status: UploadStatus.idle,
        progress: 0.0,
        error: null,
      );

      state = state.copyWith(status: UploadStatus.uploading);

      await for (final value in service.uploadFileProgress()) {
        state = state.copyWith(progress: value);
      }

      state = state.copyWith(status: UploadStatus.processing);

      final finalStatus = await service.processTrack();

      state = state.copyWith(
        status: finalStatus == 'finished'
            ? UploadStatus.finished
            : UploadStatus.failed,
        progress: 1.0,
      );

      return state.status == UploadStatus.finished;
    } catch (e) {
      state = state.copyWith(status: UploadStatus.failed, error: e.toString());
      return false;
    }
  }
}

final uploadProvider = NotifierProvider<UploadNotifier, UploadState>(UploadNotifier.new);
