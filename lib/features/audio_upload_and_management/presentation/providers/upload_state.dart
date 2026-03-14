import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/uploaded_track.dart';

class UploadState {
  final bool isLoadingQuota;
  final bool isPreparingUpload;
  final bool isUploading;
  final UploadQuota? quota;
  final PickedUploadFile? selectedAudio;
  final UploadedTrack? currentTrack;
  final double uploadProgress;
  final String? error;

  const UploadState({
    this.isLoadingQuota = false,
    this.isPreparingUpload = false,
    this.isUploading = false,
    this.quota,
    this.selectedAudio,
    this.currentTrack,
    this.uploadProgress = 0.0,
    this.error,
  });

  bool get isBusy => isPreparingUpload || isUploading;

  bool get uploadFinished =>
      !isPreparingUpload && !isUploading && uploadProgress >= 1.0;

  UploadState copyWith({
    bool? isLoadingQuota,
    bool? isPreparingUpload,
    bool? isUploading,
    UploadQuota? quota,
    PickedUploadFile? selectedAudio,
    UploadedTrack? currentTrack,
    double? uploadProgress,
    String? error,
  }) {
    return UploadState(
      isLoadingQuota: isLoadingQuota ?? this.isLoadingQuota,
      isPreparingUpload: isPreparingUpload ?? this.isPreparingUpload,
      isUploading: isUploading ?? this.isUploading,
      quota: quota ?? this.quota,
      selectedAudio: selectedAudio ?? this.selectedAudio,
      currentTrack: currentTrack ?? this.currentTrack,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
    );
  }
}
