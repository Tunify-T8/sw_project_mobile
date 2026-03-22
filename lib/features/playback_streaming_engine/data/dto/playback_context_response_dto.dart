class PlaybackContextResponseDto {
  const PlaybackContextResponseDto({
    required this.trackIds,
    required this.currentIndex,
    required this.shuffle,
    required this.repeat,
  });

  final List<String> trackIds;
  final int currentIndex;
  final bool shuffle;
  final String repeat; // 'none' | 'one' | 'all'

  factory PlaybackContextResponseDto.fromJson(Map<String, dynamic> json) {
    final queueJson = json['queue'] as List<dynamic>? ?? [];
    final trackIds = queueJson.map((e) {
      if (e is String) return e;
      if (e is Map<String, dynamic>) {
        return (e['trackId'] ?? '') as String;
      }
      return e.toString();
    }).toList();

    return PlaybackContextResponseDto(
      trackIds: trackIds,
      currentIndex: (json['currentIndex'] as int?) ?? 0,
      shuffle: (json['shuffle'] as bool?) ?? false,
      repeat: (json['repeat'] ?? 'none') as String,
    );
  }
}
