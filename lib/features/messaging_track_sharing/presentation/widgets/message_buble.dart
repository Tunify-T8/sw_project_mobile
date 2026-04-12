import 'package:flutter/material.dart';

import '../../domain/entities/message_attachment.dart';
import '../../domain/entities/message_entity.dart';
import '../utils/messaging_time_format.dart';

/// A single chat bubble — text or attachment — plus the small h:mm AM/PM
/// timestamp underneath. Matches the SoundCloud DM look: dark grey rounded
/// container with a hairline white outline, no fill colour difference between
/// incoming and outgoing (alignment alone signals direction).
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
    final alignment =
        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.74,
            ),
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
        children.add(_AttachmentChip(attachment: att));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.attachment});

  final MessageAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final icon = attachment.type == MessageAttachmentType.collection
        ? Icons.library_music_outlined
        : Icons.music_note_outlined;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              attachment.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
