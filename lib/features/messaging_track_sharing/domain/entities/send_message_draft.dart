import 'message_attachment.dart';
import 'message_entity.dart';

/// Draft supplied by the UI layer to send a message.
class SendMessageDraft {
  final MessageType type;
  final String? text;
  final List<MessageAttachment> attachments;
  const SendMessageDraft({
    required this.type,
    this.text,
    this.attachments = const [],
  });
}
