import '../../domain/entities/upload_status.dart';

class UploadStatusMapper {
  static UploadStatus fromString(String status) {
    switch (status) {
      case 'idle':
        return UploadStatus.idle;
      case 'uploading':
        return UploadStatus.uploading;
      case 'processing':
        return UploadStatus.processing;
      case 'finished':
        return UploadStatus.finished;
      case 'failed':
        return UploadStatus.failed;
      default:
        return UploadStatus.idle;
    }
  }
}