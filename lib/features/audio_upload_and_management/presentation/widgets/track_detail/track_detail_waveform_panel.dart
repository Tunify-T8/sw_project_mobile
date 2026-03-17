import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_waveform_provider.dart';
import 'track_detail_soundcloud_waveform.dart';

class TrackDetailWaveformPanel extends ConsumerWidget {
  const TrackDetailWaveformPanel({
    super.key,
    required this.item,
    required this.state,
    required this.onMoreTap,
  });

  final UploadItem item;
  final TrackDetailWaveformState state;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waveformBarsAsync = ref.watch(trackDetailWaveformBarsProvider(item));
    final bars = waveformBarsAsync.asData?.value;
    final isLoading = waveformBarsAsync.isLoading;

    final description = item.description?.trim() ?? '';
    final hasDescription = description.isNotEmpty;

    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 120, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (hasDescription) ...[
                _WaveformCommentBubble(text: description),
                const SizedBox(height: 18),
              ],
              TrackDetailSoundcloudWaveform(
                state: state,
                bars: bars,
                isLoading: isLoading,
              ),
              const SizedBox(height: 18),
              const _CommentComposerBar(),
              const SizedBox(height: 18),
              _BottomActionBar(onMoreTap: onMoreTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformCommentBubble extends StatelessWidget {
  const _WaveformCommentBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white70,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade600.withOpacity(0.72),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentComposerBar extends StatelessWidget {
  const _CommentComposerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade700.withOpacity(0.68),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Comment...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          _ReactionEmoji('🔥'),
          SizedBox(width: 14),
          _ReactionEmoji('👏'),
          SizedBox(width: 14),
          _ReactionEmoji('🥹'),
        ],
      ),
    );
  }
}

class _ReactionEmoji extends StatelessWidget {
  const _ReactionEmoji(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 28),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.onMoreTap});

  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _ActionButton(icon: Icons.favorite_border),
          const _ActionButton(icon: Icons.chat_bubble_outline),
          const _ActionButton(icon: Icons.ios_share_outlined),
          const _ActionButton(icon: Icons.playlist_play),
          _ActionButton(icon: Icons.more_horiz, onTap: onMoreTap),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}