class FeedActorEntity {
  final String id;
  final String username;
  final String? avatarUrl;

  const FeedActorEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
  });
}