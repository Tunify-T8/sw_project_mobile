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

  static NotificationType fromString(String raw) {
    final normalized = raw
        .trim()
        .replaceAll('-', '_')
        .replaceAllMapped(
          RegExp(r'(?<=[a-z0-9])[A-Z]'),
          (match) => '_${match.group(0)}',
        )
        .toLowerCase();

    return NotificationType.values.firstWhere(
      (t) => t.value == normalized,
      orElse: () => NotificationType.system,
    );
  }
}
