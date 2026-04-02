/// Centralized keys used for secure storage.
///
/// This avoids hardcoding strings across the application
/// and prevents typos when accessing stored values.
class StorageKeys {
  StorageKeys._();

  /// Key used to store the JWT access token.
  static const String accessToken = 'access_token';

  /// Key used to store the JWT refresh token.
  static const String refreshToken = 'refresh_token';

  /// Key used to store serialized user information (optional).
  static const String user = 'auth_user';

  /// Key used to store playback events queued while offline.
  static const String pendingPlaybackEvents = 'pending_playback_events';

  /// Cached first page of the listening history screen.
  static const String cachedListeningHistory = 'cached_listening_history';

  /// Track IDs played locally while offline and still waiting to be synced
  /// back to the backend once the device reconnects.
  static const String pendingHistorySyncTrackIds =
      'pending_history_sync_track_ids';

  /// Cached uploads list so the library remains usable offline.
  static const String cachedLibraryUploads = 'cached_library_uploads';
}
