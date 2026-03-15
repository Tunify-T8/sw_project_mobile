class ApiEndpoints {
  ApiEndpoints._(); // so no objects can be created

  // Because if your backend changes a path later, you only fix it in one place.

  // Replace this with your backend URL.
  // Android emulator -> use 10.0.2.2 instead of localhost.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static String uploadQuota(String userId) => '/users/$userId/upload-quota';

  static String createTrack() => '/tracks';

  static String uploadAudio(String trackId) => '/tracks/$trackId/audio';

  static String finalizeMetadata(String trackId) => '/tracks/$trackId/metadata';

  static String trackStatus(String trackId) => '/tracks/$trackId/status';

  static String trackDetails(String trackId) => '/tracks/$trackId';

  static String updateTrack(String trackId) => '/tracks/$trackId';

  static String deleteTrack(String trackId) => '/tracks/$trackId';
  static const String myUploads = '/me/uploads';
  static const String artistToolsQuota = '/me/uploads/artist-tools';

  static String uploadDetails(String trackId) => '/tracks/$trackId';
  static String deleteUpload(String trackId) => '/tracks/$trackId';
  static String replaceUploadFile(String trackId) =>
      '/tracks/$trackId/replace-file';
}
// We need a shared network layer.

// We should not repeat URL strings in repositories or APIs.

// Module 4 already has a known contract: quota, create track, upload audio, finalize metadata, poll status, details, update, delete.

// Let’s encode that contract as endpoint helpers.

// So this file is really a translation of the API contract into code.
