/// Lightweight time formatting helpers for the messaging UI.
///
/// We deliberately avoid the `intl` package here so the messaging feature has
/// no extra deps — every value the UI needs is short and locale-agnostic
/// enough that hand-rolled formatters cover it cleanly.
class MessagingTimeFormat {
  MessagingTimeFormat._();

  /// Conversation list relative timestamp — matches SoundCloud activity:
  /// "just now", "9s", "2m", "3h", "1d", "Mar 4".
  static String relativeShort(DateTime when, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(when);
    if (diff.isNegative || diff.inSeconds < 5) {
      return 'just now';
    }
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d';
    }
    return _shortMonthDay(when);
  }

  /// Bubble timestamp — h:mm AM/PM (12h) in device local time, e.g. "2:02 AM".
  static String clock12(DateTime when) {
    final local = when.toLocal();
    final hour24 = local.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = hour24 < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $suffix';
  }

  /// Used as the date separator above the first message of the day —
  /// "Today", "Yesterday", or e.g. "Mar 4".
  static String dayHeader(DateTime when, {DateTime? now}) {
    final local = when.toLocal();
    final ref = now?.toLocal() ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final that = DateTime(local.year, local.month, local.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _shortMonthDay(local);
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _shortMonthDay(DateTime when) =>
      '${_months[when.month - 1]} ${when.day}';
}
