class EngagementFormatters {
  static String timeAgo(DateTime createdAt) {
    final now = DateTime.now().toUtc();
    final time = createdAt.toUtc();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 52) return '${weeks}w';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo';
    return '${(diff.inDays / 365).floor()}y';
  }

  static String timestamp(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final minutes = safe ~/ 60;
    final remainder = (safe % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  static String compactCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  static String initials(String username) {
    final clean = username.trim();
    if (clean.isEmpty) return '?';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
