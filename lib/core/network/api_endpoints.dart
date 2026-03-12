class ApiEndpoints {
  ApiEndpoints._();

  // Replace this with your backend URL.
  // Android emulator -> use 10.0.2.2 instead of localhost.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static String uploadQuota(String userId) => '/users/$userId/upload-quota';

  static String createTrack() => '/tracks';

  static String uploadAudio(String trackId) => '/tracks/$trackId/audio';

  static String finalizeMetadata(String trackId) =>
      '/tracks/$trackId/metadata';

  static String trackStatus(String trackId) => '/tracks/$trackId/status';

  static String trackDetails(String trackId) => '/tracks/$trackId';

  static String updateTrack(String trackId) => '/tracks/$trackId';

  static String deleteTrack(String trackId) => '/tracks/$trackId';
}