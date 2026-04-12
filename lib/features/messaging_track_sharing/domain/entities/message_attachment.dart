enum MessageAttachmentType { track, collection }

class MessageAttachment {
  final String id;
  final MessageAttachmentType type;
  final String title;
  final String? subtitle;
  final String? artworkUrl;

  const MessageAttachment({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.artworkUrl,
  });
}
