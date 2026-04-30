import 'package:flutter/material.dart';

import '../state/notification_filter.dart';

/// Empty state shown when a notification filter has no results.
/// Matches the SoundCloud "You don't have any recent …" pattern.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({
    super.key,
    required this.filter,
    required this.onShowAll,
  });

  final NotificationFilter filter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    // "Show all" filter — different empty state.
    if (filter == NotificationFilter.all) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Updates from your SoundCloud\ncommunity will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filtered empty state.
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You don\'t have any recent ${filter.emptyNoun}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Switch to showing all to see recent notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onShowAll,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Show all notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
