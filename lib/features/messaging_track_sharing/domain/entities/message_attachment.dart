/// Classification of an attached piece of content in a message.
///
/// `track` / `collection` are kept as coarse UI buckets so the chat bubble
/// only has to decide between a track-like card and a collection-like card.
///
/// `backendKind` carries the exact backend message type so outgoing messages
/// (TRACK_LIKE vs TRACK_UPLOAD, PLAYLIST vs ALBUM, USER share) can be sent
/// over the websocket with the correct shape.
enum MessageAttachmentType { track, collection, user }

enum MessageAttachmentBackendKind {
  trackLike,
  trackUpload,
  playlist,
  album,
  user,
}

extension MessageAttachmentBackendKindX on MessageAttachmentBackendKind {
  /// Wire value used by the backend `type` field.
  String get wireType {
    switch (this) {
      case MessageAttachmentBackendKind.trackLike:
        return 'TRACK_LIKE';
      case MessageAttachmentBackendKind.trackUpload:
        return 'TRACK_UPLOAD';
      case MessageAttachmentBackendKind.playlist:
        return 'PLAYLIST';
      case MessageAttachmentBackendKind.album:
        return 'ALBUM';
      case MessageAttachmentBackendKind.user:
        return 'USER';
    }
  }

  MessageAttachmentType get uiType {
    switch (this) {
      case MessageAttachmentBackendKind.trackLike:
      case MessageAttachmentBackendKind.trackUpload:
        return MessageAttachmentType.track;
      case MessageAttachmentBackendKind.playlist:
      case MessageAttachmentBackendKind.album:
        return MessageAttachmentType.collection;
      case MessageAttachmentBackendKind.user:
        return MessageAttachmentType.user;
    }
  }

  static MessageAttachmentBackendKind? fromWire(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'TRACK':
      case 'TRACK_LIKE':
        return MessageAttachmentBackendKind.trackLike;
      case 'TRACK_UPLOAD':
      case 'UPLOAD':
        return MessageAttachmentBackendKind.trackUpload;
      case 'COLLECTION':
      case 'PLAYLIST':
        return MessageAttachmentBackendKind.playlist;
      case 'ALBUM':
        return MessageAttachmentBackendKind.album;
      case 'USER':
        return MessageAttachmentBackendKind.user;
      default:
        return null;
    }
  }
}

class MessageAttachment {
  final String id;
  final MessageAttachmentType type;

  /// Precise backend type. Defaults to `trackLike` for tracks and `playlist`
  /// for collections so older callers keep working even if they do not set
  /// [backendKind] explicitly.
  final MessageAttachmentBackendKind backendKind;

  final String title;
  final String? subtitle;
  final String? artworkUrl;

  /// True when this is a private track shared by the owner. Recipients see a
  /// lock icon and cannot forward the track.
  final bool isPrivate;

  /// Token required for recipients to play a privately shared track.
  final String? privateToken;

  const MessageAttachment({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.artworkUrl,
    this.isPrivate = false,
    this.privateToken,
    MessageAttachmentBackendKind? backendKind,
  }) : backendKind =
           backendKind ??
           (type == MessageAttachmentType.track
               ? MessageAttachmentBackendKind.trackLike
               : type == MessageAttachmentType.collection
               ? MessageAttachmentBackendKind.playlist
               : MessageAttachmentBackendKind.user);

  MessageAttachment copyWith({
    String? id,
    MessageAttachmentType? type,
    MessageAttachmentBackendKind? backendKind,
    String? title,
    String? subtitle,
    String? artworkUrl,
    bool? isPrivate,
    Object? privateToken = _sentinel,
  }) {
    return MessageAttachment(
      id: id ?? this.id,
      type: type ?? this.type,
      backendKind: backendKind ?? this.backendKind,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      privateToken: identical(privateToken, _sentinel)
          ? this.privateToken
          : privateToken as String?,
    );
  }
}

const Object _sentinel = Object();
