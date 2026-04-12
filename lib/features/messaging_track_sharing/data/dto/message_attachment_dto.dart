class MessageAttachmentDto {
  final String id;
  final String type; // TRACK | COLLECTION
  final String title;
  final String? subtitle;
  final String? artworkUrl;

  const MessageAttachmentDto({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.artworkUrl,
  });

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> j) =>
      MessageAttachmentDto(
        id: (j['id'] ?? '').toString(),
        type: (j['type'] ?? 'TRACK').toString().toUpperCase(),
        title: (j['title'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? j['artistName'] ?? j['ownerName']) as String?,
        artworkUrl: j['artworkUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        if (title.isNotEmpty) 'title': title,
        if (subtitle != null && subtitle!.trim().isNotEmpty) 'subtitle': subtitle,
        if (artworkUrl != null && artworkUrl!.trim().isNotEmpty)
          'artworkUrl': artworkUrl,
      };
}
