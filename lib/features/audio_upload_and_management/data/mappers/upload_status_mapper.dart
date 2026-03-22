// Upload Feature Guide:
// Purpose: Mapper/helper file that converts upload data between API, domain, and UI shapes.
// Used by: Consumed across nearby upload data and domain files.
// Concerns: Multi-format support; Transcoding logic.
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
