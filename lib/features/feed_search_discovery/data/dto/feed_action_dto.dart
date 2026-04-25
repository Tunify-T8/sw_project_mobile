class FeedActionDto {
  final String actorId;
  final String username;
  final String action;
  final String date;
  final String? avatarUrl;

  FeedActionDto({
    required this.actorId,
    required this.username,
    required this.action,
    required this.date,
    required this.avatarUrl,
  });

  factory FeedActionDto.fromJson(Map<String, dynamic> json) {
    return FeedActionDto(
      actorId: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}
