enum MessageAttachmentType { track, collection }

class MessageAttachment {
  final String id;
  final MessageAttachmentType type;
  final String title;
  final String? artworkUrl;
  const MessageAttachment({
    required this.id,
    required this.type,
    required this.title,
    this.artworkUrl,
  });
}
