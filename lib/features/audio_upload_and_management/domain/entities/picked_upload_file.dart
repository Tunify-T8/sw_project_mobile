class PickedUploadFile {
  // This class represents a file that the user has picked for upload. It contains the file's name, path, and size in bytes. This information is used to display the selected file in the UI and to manage the upload process.
  final String name;
  final String path;
  final int sizeBytes;

  const PickedUploadFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
  });
}

// so we dont use platformFile type but our own
// for business meaning
//No need to keep every field from PlatformFile if the app does not need it
