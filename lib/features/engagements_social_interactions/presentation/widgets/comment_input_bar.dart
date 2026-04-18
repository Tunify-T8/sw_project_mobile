import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../provider/enagement_providers.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final String trackId;

  const CommentInputBar({
    super.key,
    required this.trackId,
  });

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _currentTimestampSeconds() {
    return ref.read(playerProvider).value?.positionSeconds.toInt() ?? 0;
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
    await ref.read(engagementProvider(widget.trackId).notifier).addComment(
          timestamp: _currentTimestampSeconds(),
          text: text,
        );
  }

  Future<void> _sendEmoji(String emoji) async {
    await ref.read(engagementProvider(widget.trackId).notifier).addComment(
          timestamp: _currentTimestampSeconds(),
          text: emoji,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Comment...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded,
                      color: Colors.orangeAccent, size: 20),
                  onPressed: _submit,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          _EmojiButton(emoji: '🔥', onTap: () => _sendEmoji('🔥')),
          _EmojiButton(emoji: '👏', onTap: () => _sendEmoji('👏')),
          _EmojiButton(emoji: '😢', onTap: () => _sendEmoji('😢')),
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
