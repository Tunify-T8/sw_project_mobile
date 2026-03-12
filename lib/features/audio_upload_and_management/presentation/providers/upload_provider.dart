import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/uploaded_track.dart';
import 'upload_dependencies_provider.dart';
import 'upload_repository_provider.dart';
import 'upload_state.dart';

class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() {
    return const UploadState();
  }

  Future<void> loadQuota(String userId) async {
    state = state.copyWith(
      isLoadingQuota: true,
      error: null,
    );

    try {
      final repository = ref.read(uploadRepositoryProvider);
      final quota = await repository.getUploadQuota(userId);

      state = state.copyWith(
        isLoadingQuota: false,
        quota: quota,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuota: false,
        error: e.toString(),
      );
    }
  }

  Future<void> pickAudioFile() async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final file = await picker.pickAudioFile();

      if (file == null) {
        return;
      }

      state = state.copyWith(
        selectedAudio: file,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<UploadedTrack?> createTrackAndUpload(String userId) async {
    if (state.selectedAudio == null) {
      state = state.copyWith(
        error: 'Please choose an audio file first.',
      );
      return null;
    }

    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0.0,
      error: null,
    );

    try {
      final repository = ref.read(uploadRepositoryProvider);

      final createdTrack = await repository.createTrack(userId);

      state = state.copyWith(
        currentTrack: createdTrack,
      );

      final uploadedTrack = await repository.uploadAudio(
        trackId: createdTrack.trackId,
        file: state.selectedAudio!,
        onProgress: (progress) {
          state = state.copyWith(
            uploadProgress: progress,
          );
        },
      );

      state = state.copyWith(
        isUploading: false,
        currentTrack: uploadedTrack,
      );

      return uploadedTrack;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
      return null;
    }
  }
}

final uploadProvider =
    NotifierProvider<UploadNotifier, UploadState>(UploadNotifier.new);