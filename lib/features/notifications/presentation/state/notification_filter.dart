/// Filter options for the notification tab dropdown — mirrors the SoundCloud UI.
enum NotificationFilter {
  all('Show all notifications', null),
  reposts('Reposts', 'track_reposted'),
  likes('Likes', 'track_liked'),
  comments('Comments', 'track_commented'),
  followings('Followings', 'user_followed');

  const NotificationFilter(this.label, this.apiType);

  /// Human-readable label shown in the dropdown.
  final String label;

  /// The `type` query parameter sent to the API. Null means no filter.
  final String? apiType;

  /// The empty-state noun (e.g. "You don't have any recent reposts").
  String get emptyNoun {
    switch (this) {
      case NotificationFilter.all:
        return 'notifications';
      case NotificationFilter.reposts:
        return 'reposts';
      case NotificationFilter.likes:
        return 'likes';
      case NotificationFilter.comments:
        return 'comments';
      case NotificationFilter.followings:
        return 'followers';
    }
  }
}
