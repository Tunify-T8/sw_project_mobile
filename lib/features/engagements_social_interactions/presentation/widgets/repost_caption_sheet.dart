import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';
import '../provider/enagement_providers.dart';

class RepostCaptionSheet extends ConsumerStatefulWidget {
  const RepostCaptionSheet({
    super.key,
    required this.trackId,
    required this.trackTitle,
    required this.artistName,
    this.coverUrl,
  });

  final String trackId;
  final String trackTitle;
  final String artistName;
  final String? coverUrl;

  static Future<void> show(
    BuildContext context, {
    required String trackId,
    required String trackTitle,
    required String artistName,
    String? coverUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RepostCaptionSheet(
        trackId: trackId,
        trackTitle: trackTitle,
        artistName: artistName,
        coverUrl: coverUrl,
      ),
    );
  }

  @override
  ConsumerState<RepostCaptionSheet> createState() => _RepostCaptionSheetState();
}

class _RepostCaptionSheetState extends ConsumerState<RepostCaptionSheet> {
  final _captionController = TextEditingController();
  bool _hasCaption = false;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(() {
      setState(() => _hasCaption = _captionController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _repost() {
    final caption = _hasCaption ? _captionController.text.trim() : null;
    ref.read(engagementProvider(widget.trackId).notifier).repostTrack(caption: caption);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authControllerProvider).value;
    final profile = ref.watch(profileProvider).profile;
    final username = authUser?.username ?? 'You';
    final avatarUrl = profile?.profileImagePath ?? authUser?.avatarUrl;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // User row + caption field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.repeat, color: Colors.white54, size: 16),
                        ],
                      ),
                      TextField(
                        controller: _captionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        minLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Add a caption (optional)',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Track preview card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
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
                            errorBuilder: (_, __, ___) => _coverPlaceholder(),
                          )
                        : _coverPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.trackTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.music_note, color: Colors.white54, size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.artistName,
                                style: const TextStyle(color: Colors.white54, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Repost button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _repost,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _hasCaption ? 'Repost' : 'Repost without caption',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your 1 follower sees this repost',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        width: 48,
        height: 48,
        color: Colors.white12,
        child: const Icon(Icons.music_note, color: Colors.white30, size: 22),
      );
}
