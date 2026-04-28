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

  /// Cached listening history shown in the app.
  static const String cachedListeningHistory = 'cached_listening_history';

  /// Local flag used only when the user explicitly clears history.
  ///
  /// We keep this separate from the cached list so the app does not rehydrate
  /// old backend history on the next launch after a local clear.
  static const String historyClearedLocally = 'history_cleared_locally';

  /// ISO-8601 timestamp recorded when the user clears their listening history.
  /// On subsequent backend sync, any history entries older than this timestamp
  /// are dropped — protects against the backend's clear endpoint silently
  /// failing and re-serving the pre-clear list on next launch.
  static const String historyClearedAt = 'history_cleared_at';

  static const String cachedLibraryUploads = 'cached_library_uploads';
  static const String cachedPlayerSession = 'cached_player_session';
  static const String messagingReadWatermarks = 'messaging_read_watermarks';

  /// Plays that happened while offline, waiting to be sent via
  /// `POST /tracks/plays/batch` when the device comes back online.
  static const String pendingOfflinePlays = 'pending_offline_plays';
}
