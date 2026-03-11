enum UploadStatus {
  idle,
  // preparingToUpload,   // tell backend
  uploading,
  // preparingToProcess,  // tell backend
  processing,
  finished,
  failed,
}