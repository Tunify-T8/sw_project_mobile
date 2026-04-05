part of 'track_info_screen.dart';

class _MockTrackStats {
  const _MockTrackStats({
    required this.playCountText,
    required this.likeCountText,
    required this.commentCountText,
    required this.repostCountText,
    required this.releaseDateText,
  });

  final String playCountText;
  final String likeCountText;
  final String commentCountText;
  final String repostCountText;
  final String releaseDateText;

  factory _MockTrackStats.fromItem(UploadItem item) {
    final seed = item.id.hashCode.abs();
    final playCount = 450000 + (seed % 900000);
    final likes = 14000 + (seed % 22000);
    final comments = 70 + (seed % 300);
    final reposts = 40 + (seed % 220);
    final date = item.createdAt;

    return _MockTrackStats(
      playCountText: _compactNumber(playCount),
      likeCountText: _compactNumber(likes),
      commentCountText: '$comments',
      repostCountText: '$reposts',
      releaseDateText: '${date.day} ${_monthName(date.month)} ${date.year}',
    );
  }

  static String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[((month - 1).clamp(0, 11) as num).toInt()];
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({required this.name, required this.plays});

  final String name;
  final int plays;
}

List<_LeaderboardEntry> _mockLeaderboard(UploadItem item) {
  final seed = item.id.hashCode.abs();
  const names = [
    'Mody Mohamed',
    'Reham Kareem',
    'User 921620114',
    'Adam Sharif',
    'Abdalrahman Ahmed',
  ];

  return List.generate(names.length, (index) {
    final plays = 110 + ((seed + index * 29) % 140);
    return _LeaderboardEntry(name: names[index], plays: plays);
  });
}

class _PlaylistCardData {
  const _PlaylistCardData({
    required this.title,
    required this.owner,
    required this.icon,
    required this.color,
  });

  final String title;
  final String owner;
  final IconData icon;
  final Color color;
}

List<_PlaylistCardData> _mockPlaylists(UploadItem item) {
  final safeArtist = item.artistDisplay.split(',').first.trim();

  return const [
    _PlaylistCardData(
      title: 'Summer Nights',
      owner: 'Mosaab',
      icon: Icons.nights_stay_outlined,
      color: Color(0xFF6A4B2B),
    ),
    _PlaylistCardData(
      title: 'el lol',
      owner: 'Wilo Ellol',
      icon: Icons.mic_none_rounded,
      color: Color(0xFF8B6B49),
    ),
    _PlaylistCardData(
      title: 'Arabic',
      owner: 'Mirzana',
      icon: Icons.queue_music_rounded,
      color: Color(0xFF3E2C23),
    ),
  ].map((playlist) {
    if (playlist.title == 'Summer Nights') {
      return _PlaylistCardData(
        title: item.title,
        owner: safeArtist.isEmpty ? playlist.owner : safeArtist,
        icon: playlist.icon,
        color: playlist.color,
      );
    }
    return playlist;
  }).toList();
}
