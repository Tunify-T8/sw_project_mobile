import 'message_attachment.dart';
import 'message_entity.dart';

/// Draft supplied by the UI layer to send a message.
///
/// The backend expects exactly one top-level [MessageType] per message:
/// either TEXT (plus `content`) or one of TRACK_LIKE/TRACK_UPLOAD/PLAYLIST/
/// ALBUM/USER (plus the matching fk: `trackId`/`collectionId`/`userId`).
///
/// Multiple attachments are supported at the UI layer by sending multiple
/// messages back-to-back through the repository.
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
