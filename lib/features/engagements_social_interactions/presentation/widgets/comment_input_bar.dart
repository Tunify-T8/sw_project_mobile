import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../data/services/mock_engagement_store.dart';
import '../provider/enagement_providers.dart';
import '../utils/engagement_formatters.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  const CommentInputBar({
    super.key,
    required this.trackId,
    this.replyingToCommentId,
    this.prefillText,
    this.onReplyClear,
    this.showEmojis = true,
    this.useSafeArea = false,
  });

  final String trackId;

  /// Non-null when the user is replying to a specific comment.
  final String? replyingToCommentId;

  /// Pre-fills the text field (e.g. "@username ") when entering reply mode.
  final String? prefillText;

  /// Called after a reply is submitted so the parent can reset reply state.
  final VoidCallback? onReplyClear;

  /// true  → waveform panel style: send icon inside field + emoji buttons
  /// false → comments screen style: send icon outside field, no emojis
  final bool showEmojis;

  /// Wraps the bar in a [SafeArea] — needed when rendered at the bottom of a screen.
  final bool useSafeArea;

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void didUpdateWidget(CommentInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.prefillText != null &&
        widget.prefillText != oldWidget.prefillText) {
      _controller.text = widget.prefillText!;
      _controller.selection =
          TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
      _focusNode.requestFocus();
    }
    if (widget.prefillText == null && oldWidget.prefillText != null) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int? _currentTimestampSeconds() {
    final playerState = ref.read(playerProvider).value;
    if (playerState?.bundle?.trackId != widget.trackId) return null;
    return playerState?.positionSeconds.toInt();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();

    final replyTarget = widget.replyingToCommentId;
    if (replyTarget != null) {
      final authUser = ref.read(authControllerProvider).value;
      if (authUser != null) {
        ref.read(mockEngagementStoreProvider).seedUser(
          id: authUser.id,
          username: authUser.username,
          avatarUrl: authUser.avatarUrl,
        );
      }
      await ref.read(addReplyUsecaseProvider).call(
            commentId: replyTarget,
            viewerId: authUser?.id ?? 'user_current_1',
            text: text,
          );
      await ref.read(engagementProvider(widget.trackId).notifier).loadComments();
      widget.onReplyClear?.call();
    } else {
      await ref.read(engagementProvider(widget.trackId).notifier).addComment(
            timestamp: _currentTimestampSeconds(),
            text: text,
          );
    }
  }

  Future<void> _sendEmoji(String emoji) async {
    await ref.read(engagementProvider(widget.trackId).notifier).addComment(
          timestamp: _currentTimestampSeconds(),
          text: emoji,
        );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider).value;
    final isThisTrackActive = playerState?.bundle?.trackId == widget.trackId;
    final seconds = isThisTrackActive ? (playerState?.positionSeconds.toInt() ?? 0) : null;

    final hintText = widget.replyingToCommentId != null
        ? 'Write a reply...'
        : seconds != null
            ? 'Comment at ${EngagementFormatters.timestamp(seconds)}'
            : widget.showEmojis
                ? 'Comment...'
                : 'Add a comment...';

    Widget bar = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: widget.showEmojis
          ? Colors.black.withOpacity(0.5)
          : const Color(0xFF242424),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                filled: true,
                fillColor: widget.showEmojis
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white10,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: widget.showEmojis
                    ? IconButton(
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.orangeAccent, size: 20),
                        onPressed: _submit,
                      )
                    : null,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          if (widget.showEmojis) ...[
            const SizedBox(width: 8),
            _EmojiButton(emoji: '🔥', onTap: () => _sendEmoji('🔥')),
            _EmojiButton(emoji: '👏', onTap: () => _sendEmoji('👏')),
            _EmojiButton(emoji: '😢', onTap: () => _sendEmoji('😢')),
          ] else ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, color: Colors.orangeAccent),
            ),
          ],
        ],
      ),
    );

    return widget.useSafeArea ? SafeArea(child: bar) : bar;
  }
}

class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

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
