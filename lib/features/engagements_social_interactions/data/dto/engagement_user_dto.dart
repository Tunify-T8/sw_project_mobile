class EngagementUserDto {
  const EngagementUserDto({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? avatarUrl;

  factory EngagementUserDto.fromJson(Map<String, dynamic> json) {
    return EngagementUserDto(
      id: (json['id'] as String?) ?? (json['userId'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
    };
  }
}
