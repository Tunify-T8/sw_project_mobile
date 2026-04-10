import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../provider/enagement_providers.dart';

class CommentInputBar extends ConsumerWidget {
  final String trackId;
  final VoidCallback onTap; 

  const CommentInputBar({
    super.key,
    required this.trackId,
    required this.onTap,
  });

  int _currentTimestampSeconds(WidgetRef ref) {
    return ref.read(playerProvider).value?.positionSeconds.toInt() ?? 0;
  }

  Future<void> _sendEmoji(WidgetRef ref, String emoji) async {
    await ref.read(engagementProvider(trackId).notifier).addComment(
          timestamp: _currentTimestampSeconds(ref),
          text: emoji,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Comment...',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _EmojiButton(emoji: '🔥', onTap: () => _sendEmoji(ref, '🔥')),
          _EmojiButton(emoji: '👏', onTap: () => _sendEmoji(ref, '👏')),
          _EmojiButton(emoji: '😢', onTap: () => _sendEmoji(ref, '😢')),
        ],
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiButton({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
