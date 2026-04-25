class EngagementUserDto {
  const EngagementUserDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isCertified = false,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isCertified;

  factory EngagementUserDto.fromJson(Map<String, dynamic> json) {
    return EngagementUserDto(
      id: (json['id'] as String?) ?? (json['userId'] as String?) ?? '',
      displayName: (json['displayName'] as String?)?.isNotEmpty == true
          ? json['displayName'] as String
          : (json['username'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isCertified: (json['isCertified'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isCertified': isCertified,
    };
  }
}
