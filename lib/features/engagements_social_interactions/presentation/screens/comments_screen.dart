import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/playback_streaming_engine/presentation/providers/player_provider.dart';
import '../provider/enagement_providers.dart';
import '../provider/engagement_state.dart';
import '../utils/engagement_formatters.dart';
import '../widgets/comment_tile.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.trackId});

  final String trackId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _replyingToCommentId; // engagement addition — tracks which comment the user is replying to

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementProvider(widget.trackId).notifier).loadComments();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _currentTimestampSeconds {
    final playerState = ref.read(playerProvider).value;
    return playerState?.positionSeconds.toInt() ?? 0;
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final replyTarget = _replyingToCommentId; // engagement addition — capture before clearing
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _replyingToCommentId = null);

    if (replyTarget != null) {
      // engagement addition — submit as a reply instead of a top-level comment
      await ref.read(addReplyUsecaseProvider).call(
            commentId: replyTarget,
            viewerId: 'user_current_1',
            text: text,
          );
      await ref.read(engagementProvider(widget.trackId).notifier).loadComments();
    } else {
      final timestamp = _currentTimestampSeconds;
      await ref.read(engagementProvider(widget.trackId).notifier).addComment(
            timestamp: timestamp,
            text: text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementProvider(widget.trackId));
    final totalCount = state.totalCommentsCount;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: const BackButton(color: Colors.white),
        title: Text(
          '$totalCount comments',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildList(state),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildList(EngagementState state) {
    if (state.commentsStatus == EngagementStatus.loading &&
        state.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.commentsStatus == EngagementStatus.error) {
      return Center(
        child: Text(
          state.error ?? 'Something went wrong',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    if (state.comments.isEmpty) {
      return const Center(
        child: Text(
          'No comments yet. Be the first!',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: state.comments.length,
      itemBuilder: (context, index) {
        final comment = state.comments[index];
        return CommentTile(
          comment: comment,
          trackId: widget.trackId,
          onTapTimestamp: (seconds) {
            final currentTrackId = ref
                .read(playerProvider)
                .value
                ?.bundle
                ?.trackId;
            if (currentTrackId == widget.trackId) {
              ref.read(playerProvider.notifier).seek(seconds.toDouble());
              Navigator.pop(context);
            }
          },
          onReply: (username) {
            setState(() => _replyingToCommentId = comment.id); // engagement addition — mark which comment we're replying to
            _controller.text = '@$username ';
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
            _focusNode.requestFocus();
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    final playerState = ref.watch(playerProvider).value;
    final seconds = playerState?.positionSeconds.toInt() ?? 0;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: const Color(0xFF242424),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Comment at ${EngagementFormatters.timestamp(seconds)}',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, color: Colors.orangeAccent),
            ),
          ],
        ),
      ),
    );
  }
}
