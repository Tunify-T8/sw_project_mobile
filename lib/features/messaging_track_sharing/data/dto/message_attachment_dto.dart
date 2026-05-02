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
  final bool isPrivate;
  final String? privateToken;

  const MessageAttachmentDto({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.artworkUrl,
    this.isPrivate = false,
    this.privateToken,
  });

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> j) {
    // Backend-shape: `attachment: { id, type, preview: { ... } }`
    final preview = (j['preview'] is Map<String, dynamic>)
        ? j['preview'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final rawType = (j['type'] ?? preview['type'] ?? 'TRACK_LIKE').toString();

    final title =
        (j['title'] ??
                preview['title'] ??
                preview['username'] ??
                preview['displayName'] ??
                '')
            .toString();

    final subtitle =
        (j['subtitle'] ??
                preview['artistName'] ??
                preview['ownerName'] ??
                preview['subtitle'])
            as String?;

    final artwork =
        (j['artworkUrl'] ??
                j['coverUrl'] ??
                j['avatarUrl'] ??
                preview['artworkUrl'] ??
                preview['coverUrl'] ??
                preview['avatarUrl'])
            as String?;

    final isPrivate =
        _bool(j['isPrivate'] ?? preview['isPrivate']) ||
        _string(j['privacy'] ?? preview['privacy']).toLowerCase() == 'private';

    final privateToken = _nullableString(
      j['privateToken'] ??
          j['private_token'] ??
          preview['privateToken'] ??
          preview['private_token'],
    );

    return MessageAttachmentDto(
      id: (j['id'] ?? preview['id'] ?? '').toString(),
      type: rawType.toUpperCase(),
      title: title,
      subtitle: subtitle,
      artworkUrl: artwork,
      isPrivate: isPrivate,
      privateToken: privateToken,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (title.isNotEmpty) 'title': title,
    if (subtitle != null && subtitle!.trim().isNotEmpty) 'subtitle': subtitle,
    if (artworkUrl != null && artworkUrl!.trim().isNotEmpty)
      'artworkUrl': artworkUrl,
    if (isPrivate) 'isPrivate': true,
    if (privateToken != null && privateToken!.trim().isNotEmpty)
      'privateToken': privateToken,
  };

  MessageAttachmentDto copyWith({
    String? id,
    String? type,
    String? title,
    String? subtitle,
    String? artworkUrl,
    bool? isPrivate,
    Object? privateToken = _sentinel,
  }) {
    return MessageAttachmentDto(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      privateToken: identical(privateToken, _sentinel)
          ? this.privateToken
          : privateToken as String?,
    );
  }

  static bool _bool(Object? value) => value is bool && value;

  static String _string(Object? value) => value?.toString().trim() ?? '';

  static String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }
}

const Object _sentinel = Object();
