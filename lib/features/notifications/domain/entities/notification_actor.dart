/// The user who triggered the notification (e.g. the person who liked or followed).
class NotificationActor {
  final String id;
  final String username;
  final String? avatarUrl;

  const NotificationActor({
    required this.id,
    required this.username,
    this.avatarUrl,
  });
}
