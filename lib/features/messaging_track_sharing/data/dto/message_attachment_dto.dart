class MessageAttachmentDto {
  final String id;
  final String type; // TRACK | COLLECTION
  final String title;
  final String? artworkUrl;
  const MessageAttachmentDto({
    required this.id,
    required this.type,
    required this.title,
    this.artworkUrl,
  });

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> j) => MessageAttachmentDto(
        id: (j['id'] ?? '').toString(),
        type: (j['type'] ?? 'TRACK').toString().toUpperCase(),
        title: (j['title'] ?? '').toString(),
        artworkUrl: j['artworkUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'type': type};
}
