import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/enagement_providers.dart';
import '../provider/engagement_state.dart';
import '../utils/engagement_formatters.dart';
import '../widgets/comment_input_bar.dart';
import '../widgets/comment_tile.dart';
import '../../../../features/playback_streaming_engine/presentation/providers/player_provider.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({
    super.key,
    required this.trackId,
    this.coverUrl,
    this.trackTitle,
    this.artistName,
  });

  final String trackId;
  final String? coverUrl;
  final String? trackTitle;
  final String? artistName;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  String? _replyingToCommentId;
  String? _prefillText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementProvider(widget.trackId).notifier).loadComments();
    });
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
          _buildTrackHeader(),
          _buildReactionsStripe(totalCount),
          Expanded(child: _buildList(state)),
          CommentInputBar(
            trackId: widget.trackId,
            replyingToCommentId: _replyingToCommentId,
            prefillText: _prefillText,
            onReplyClear: () => setState(() {
              _replyingToCommentId = null;
              _prefillText = null;
            }),
            showEmojis: false,
            useSafeArea: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackHeader() {
    if (widget.trackTitle == null && widget.coverUrl == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1A1A1A),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: widget.coverUrl != null
                ? Image.network(
                    widget.coverUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderCover(),
                  )
                : _placeholderCover(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.trackTitle != null)
                  Text(
                    widget.trackTitle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.artistName != null)
                  Text(
                    widget.artistName!,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderCover() => Container(
        width: 48,
        height: 48,
        color: Colors.white12,
        child: const Icon(Icons.music_note, color: Colors.white30, size: 22),
      );

  Widget _buildReactionsStripe(int commentsCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF222222),
        border: Border(
          top: BorderSide(color: Colors.white12),
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          const Text('👋', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          const Text('😍', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          const Text(
            '148',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            '$commentsCount comments',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildList(EngagementState state) {
    if (state.commentsStatus == EngagementStatus.loading) {
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
        // Key: EngagementKeys.commentTile (ValueKey per comment)
        return CommentTile(
          key: ValueKey('comment_tile_${comment.id}'),
          comment: comment,
          trackId: widget.trackId,
          onTapTimestamp: (seconds) {
            final currentTrackId =
                ref.read(playerProvider).value?.bundle?.trackId;
            if (currentTrackId == widget.trackId) {
              ref.read(playerProvider.notifier).seek(seconds.toDouble());
              Navigator.pop(context);
            }
          },
          onReply: (username) {
            setState(() {
              _replyingToCommentId = comment.id;
              _prefillText = '@$username ';
            });
          },
        );
      },
    );
  }
}
