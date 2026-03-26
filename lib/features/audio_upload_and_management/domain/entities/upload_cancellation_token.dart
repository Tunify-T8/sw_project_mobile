// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_api, cloudinary_upload_repository_impl, cloudinary_upload_workflow, and 5 more upload files.
// Concerns: Multi-format support.
typedef UploadCancellationListener = void Function();

class UploadCancellationToken {
  final List<UploadCancellationListener> _listeners = [];
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void addListener(UploadCancellationListener listener) {
    if (_isCancelled) {
      listener();
      return;
    }

    _listeners.add(listener);
  }

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;

    for (final listener in List<UploadCancellationListener>.from(_listeners)) {
      listener();
    }
    _listeners.clear();
  }
}
