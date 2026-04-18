/// Mirrors the backend NotificationType enum exactly.
enum NotificationType {
  trackLiked('track_liked'),
  trackCommented('track_commented'),
  trackReposted('track_reposted'),
  userFollowed('user_followed'),
  newRelease('new_release'),
  newMessage('new_message'),
  system('system'),
  subscription('subscription');

  const NotificationType(this.value);

  /// The snake_case value used by the REST API.
  final String value;

  static NotificationType fromString(String raw) =>
      NotificationType.values.firstWhere(
        (t) => t.value == raw,
        orElse: () => NotificationType.system,
      );
}
