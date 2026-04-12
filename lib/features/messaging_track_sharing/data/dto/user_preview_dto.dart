class UserPreviewDto {
  final String id;
  final String displayName;
  final String? avatarUrl;
  const UserPreviewDto({required this.id, required this.displayName, this.avatarUrl});

  factory UserPreviewDto.fromJson(Map<String, dynamic> j) => UserPreviewDto(
        id: (j['id'] ?? '').toString(),
        displayName: (j['displayName'] ?? j['username'] ?? '').toString(),
        avatarUrl: j['avatarUrl'] as String?,
      );
}
