/// Wire-level representation of a message attachment.
///
/// The backend models attachments polymorphically: a message has a single
/// `type` (TRACK_LIKE / TRACK_UPLOAD / PLAYLIST / ALBUM / USER) plus a
/// matching foreign-key field. Inside the `attachment` object we get a
/// `preview` blob with the display fields. This DTO normalizes all of that
/// into a single flat structure the mapper can consume directly.
class MessageAttachmentDto {
  final String id;

  /// Raw wire type: TRACK | COLLECTION | USER |
  /// TRACK_LIKE | TRACK_UPLOAD | PLAYLIST | ALBUM.
  /// The mapper collapses it into the domain enum.
  final String type;

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

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> j) {
    // Backend-shape: `attachment: { id, type, preview: { ... } }`
    final preview = (j['preview'] is Map<String, dynamic>)
        ? j['preview'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final rawType = (j['type'] ?? preview['type'] ?? 'TRACK_LIKE').toString();

    final title = (j['title'] ??
            preview['title'] ??
            preview['username'] ??
            preview['displayName'] ??
            '')
        .toString();

    final subtitle = (j['subtitle'] ??
            preview['artistName'] ??
            preview['ownerName'] ??
            preview['subtitle']) as String?;

    final artwork = (j['artworkUrl'] ??
            preview['artworkUrl'] ??
            preview['coverUrl'] ??
            preview['avatarUrl']) as String?;

    return MessageAttachmentDto(
      id: (j['id'] ?? preview['id'] ?? '').toString(),
      type: rawType.toUpperCase(),
      title: title,
      subtitle: subtitle,
      artworkUrl: artwork,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        if (title.isNotEmpty) 'title': title,
        if (subtitle != null && subtitle!.trim().isNotEmpty) 'subtitle': subtitle,
        if (artworkUrl != null && artworkUrl!.trim().isNotEmpty)
          'artworkUrl': artworkUrl,
      };
}
