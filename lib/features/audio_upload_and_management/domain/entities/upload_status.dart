// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_mappers, upload_status_mapper, and 10 more upload files.
// Concerns: Multi-format support; Transcoding logic.
enum UploadStatus {
  idle,
  // preparingToUpload,   // tell backend
  uploading,
  // preparingToProcess,  // tell backend
  processing,
  finished,
  failed,
  deleted,
}
