import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/presentation/utils/track_link_helper.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../../audio_upload_and_management/presentation/widgets/upload_artwork_view.dart';
import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../utils/messaging_time_format.dart';

/// A single chat bubble — text or attachment — plus the small h:mm AM/PM
/// timestamp underneath.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final MessageEntity message;
  final bool isMine;

  static const _bg = Color(0xFF1B1B1B);
  static const _border = Color(0xFF2A2A2A);
  static const _timestampColor = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    final alignment = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final width = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = width >= 1024 ? 540.0 : width * 0.74;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: _Bubble(
              opacity: message.isPending ? 0.6 : 1.0,
              child: _BubbleContent(message: message),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            MessagingTimeFormat.clock12(message.createdAt),
            style: const TextStyle(
              color: _timestampColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (message.isFailed)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Not delivered',
                style: TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.child, this.opacity = 1.0});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: MessageBubble._bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: MessageBubble._border, width: 0.8),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({required this.message});

  final MessageEntity message;

  @override
  Widget build(BuildContext context) {
    final hasText = (message.text ?? '').isNotEmpty;
    final hasAttachments = message.attachments.isNotEmpty;
    if (!hasText && !hasAttachments) {
      return const Text('');
    }

    final children = <Widget>[];
    if (hasText) {
      children.add(Text(message.text!));
    }
    if (hasAttachments) {
      if (children.isNotEmpty) children.add(const SizedBox(height: 8));
      for (final att in message.attachments) {
        children.add(_AttachmentCard(attachment: att));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _AttachmentCard extends ConsumerWidget {
  const _AttachmentCard({required this.attachment});

  final MessageAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTrack = attachment.type == MessageAttachmentType.track;
    final icon = isTrack ? Icons.music_note_outlined : Icons.library_music_outlined;

    return InkWell(
      onTap: () => _open(context, ref),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UploadArtworkView(
              width: 56,
              height: 56,
              localPath: _localArtworkPath(attachment.artworkUrl),
              remoteUrl: _remoteArtworkUrl(attachment.artworkUrl),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              placeholder: _artworkPlaceholder(),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(icon, color: Colors.white70, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            attachment.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          if (attachment.subtitle != null &&
                              attachment.subtitle!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              attachment.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    if (attachment.type == MessageAttachmentType.collection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Collection preview ready for "${attachment.title}".'),
          backgroundColor: const Color(0xFF2A2A2A),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final trackId = attachment.id.trim();
    if (trackId.isEmpty) return;

    final store = ref.read(globalTrackStoreProvider);
    final uploadItem = store.find(trackId);

    if (uploadItem != null) {
      await openUploadItemPlayer(context, ref, uploadItem);
      return;
    }

    // Fallback: open the track by id using the existing track link helper.
    // TrackDetailScreen + ensureUploadItemPlayback will fetch the real bundle.
    await TrackLinkHelper.openTrackByIdAndToken(context, ref, trackId);
  }

  String? _localArtworkPath(String? artwork) {
    if (artwork == null || artwork.trim().isEmpty) return null;
    return artwork.startsWith('http') ? null : artwork;
  }

  String? _remoteArtworkUrl(String? artwork) {
    if (artwork == null || artwork.trim().isEmpty) return null;
    return artwork.startsWith('http') ? artwork : null;
  }

  static Widget _artworkPlaceholder() => Container(
        width: 56,
        height: 56,
        color: const Color(0xFF2A2A2A),
        child: const Icon(Icons.music_note, color: Color(0xFF5A5A5A), size: 26),
      );
}
