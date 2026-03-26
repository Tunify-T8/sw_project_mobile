// Upload Feature Guide:
// Purpose: Immutable snapshot of the active upload flow, including quota, selected audio, progress, errors, and draft status.
// Used by: upload_provider
// Concerns: Multi-format support.
import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/uploaded_track.dart';

class UploadState {
  final bool isLoadingQuota;
  final bool isPreparingUpload;
  final bool isUploading;
  final bool isCompletingUpload;
  final bool hasUploadedAudio;
  final UploadQuota? quota;
  final PickedUploadFile? selectedAudio;
  final UploadedTrack? currentTrack;
  final double uploadProgress;
  final String? error;

  /// Null = no quota-block popup is needed.
  final int? blockedUploadMinutes;

  const UploadState({
    this.isLoadingQuota = false,
    this.isPreparingUpload = false,
    this.isUploading = false,
    this.isCompletingUpload = false,
    this.hasUploadedAudio = false,
    this.quota,
    this.selectedAudio,
    this.currentTrack,
    this.uploadProgress = 0.0,
    this.error,
    this.blockedUploadMinutes,
  });

  bool get isBusy => isPreparingUpload || isUploading || isCompletingUpload;

  bool get uploadFinished =>
      hasUploadedAudio && !isPreparingUpload && !isUploading;

  bool get shouldShowQuotaLimitPrompt => blockedUploadMinutes != null;

  UploadState copyWith({
    bool? isLoadingQuota,
    bool? isPreparingUpload,
    bool? isUploading,
    bool? isCompletingUpload,
    bool? hasUploadedAudio,
    UploadQuota? quota,
    PickedUploadFile? selectedAudio,
    bool clearSelectedAudio = false,
    UploadedTrack? currentTrack,
    bool clearCurrentTrack = false,
    double? uploadProgress,
    String? error,
    int? blockedUploadMinutes,
    bool clearBlockedUploadMinutes = false,
  }) {
    return UploadState(
      isLoadingQuota: isLoadingQuota ?? this.isLoadingQuota,
      isPreparingUpload: isPreparingUpload ?? this.isPreparingUpload,
      isUploading: isUploading ?? this.isUploading,
      isCompletingUpload: isCompletingUpload ?? this.isCompletingUpload,
      hasUploadedAudio: hasUploadedAudio ?? this.hasUploadedAudio,
      quota: quota ?? this.quota,
      selectedAudio: clearSelectedAudio
          ? null
          : selectedAudio ?? this.selectedAudio,
      currentTrack: clearCurrentTrack
          ? null
          : currentTrack ?? this.currentTrack,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
      blockedUploadMinutes: clearBlockedUploadMinutes
          ? null
          : blockedUploadMinutes ?? this.blockedUploadMinutes,
    );
  }
}
