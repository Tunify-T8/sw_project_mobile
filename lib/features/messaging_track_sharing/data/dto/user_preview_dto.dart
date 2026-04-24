class UserPreviewDto {
  final String id;
  final String displayName;
  final String? avatarUrl;
  const UserPreviewDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserPreviewDto.fromJson(Map<String, dynamic> j) => UserPreviewDto(
        id: (j['id'] ?? j['userId'] ?? '').toString(),
        displayName:
            (j['displayName'] ?? j['username'] ?? j['name'] ?? '').toString(),
        avatarUrl: j['avatarUrl'] as String?,
      );
}
