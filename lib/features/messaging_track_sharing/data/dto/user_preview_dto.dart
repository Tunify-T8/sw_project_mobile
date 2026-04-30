class UserPreviewDto {
  final String id;
  final String displayName;
  final String? avatarUrl;
  const UserPreviewDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserPreviewDto.fromJson(Map<String, dynamic> j) {
    final id = _string(
      j['id'] ??
          j['_id'] ??
          j['userId'] ??
          j['user_id'] ??
          j['profileId'] ??
          j['profile_id'],
    );
    final displayName = _firstUsableName([
      j['username'],
      j['userName'],
      j['displayName'],
      j['display_name'],
      j['name'],
      j['fullName'],
      j['full_name'],
      j['email'],
    ]);

    return UserPreviewDto(
      id: id,
      displayName: displayName.isNotEmpty
          ? displayName
          : (id.isNotEmpty ? _friendlyDisplayName(id) : 'Unknown User'),
      avatarUrl: _nullableString(
        j['avatarUrl'] ??
            j['avatar_url'] ??
            j['profileImagePath'] ??
            j['profile_image_path'] ??
            j['imageUrl'] ??
            j['image_url'] ??
            j['photoUrl'] ??
            j['photo_url'],
      ),
    );
  }

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }

  static String _firstUsableName(List<Object?> values) {
    for (final value in values) {
      final text = _string(value);
      if (text.isNotEmpty && !_isPlaceholderName(text)) return text;
    }
    return '';
  }

  static bool _isPlaceholderName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'unknown display name' ||
        normalized == 'unknown user' ||
        normalized == 'unknown';
  }

  static String _friendlyDisplayName(String raw) {
    final emailName = raw.contains('@') ? raw.split('@').first : raw;
    final cleaned = emailName.replaceAll(RegExp(r'[_:-]+'), ' ').trim();
    if (cleaned.isEmpty) return raw;
    return cleaned
        .split(RegExp(r'\s+'))
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
