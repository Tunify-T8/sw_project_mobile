abstract class Routes {
  Routes._();

  static const String shell = '/shell';
  static const String uploadEntry = '/upload-entry';
  static const String trackMetadata = '/track-metadata';
  static const String uploadProgress = '/upload-progress';
  static const String editTrack = '/edit-track';
  static const String yourUploads = '/your-uploads';
  static const String trackDetail = '/track-detail';

  // Module 5 — Playback
  static const String player = '/player';
  static const String queue = '/queue';
  static const String listeningHistory = '/listening-history';

  // Module 9 — Messaging
  static const String messagingActivity = '/messaging-activity';
  static const String chat = '/chat';
  static const String inboxSettings = '/inbox-settings';

  // Module 10 — Notifications
  static const String notificationPreferences = '/notification-preferences';

  // Module 7 — Playlists & Sets
  static const String playlists = '/playlists';
  static const String playlistDetail = '/playlist-detail';
  static const String playlistEdit = '/playlist-edit';
}
