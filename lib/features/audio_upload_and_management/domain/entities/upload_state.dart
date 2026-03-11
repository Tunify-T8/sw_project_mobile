import 'upload_status.dart';



class UploadState {
  final bool isLoadingQuota;  //might not be used
  final String tier; // get from enum 
  final int uploadMinutesRemaining;

  final String? selectedFileName;
  final String? selectedFilePath;
  final String? trackId;

  final UploadStatus status; // idle, uploading, processing, finished, failed //might add preparing to upload preparing to process // see enum 
  final double progress; // 0.0 to 1.0 % in view

  final String? error; 

  const UploadState({
    this.isLoadingQuota = false,
    this.tier = '',
    this.uploadMinutesRemaining = 0,
    this.selectedFileName,
    this.selectedFilePath,
    this.trackId,
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.error,
  });

  UploadState copyWith({
    bool? isLoadingQuota,
    String? tier,
    int? uploadMinutesRemaining,
    String? selectedFileName,
    String? selectedFilePath,
    String? trackId,
    UploadStatus? status,
    double? progress,
    String? error,
  }) {
    return UploadState(
      isLoadingQuota: isLoadingQuota ?? this.isLoadingQuota,
      tier: tier ?? this.tier,
      uploadMinutesRemaining:
          uploadMinutesRemaining ?? this.uploadMinutesRemaining,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      trackId: trackId ?? this.trackId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}