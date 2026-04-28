class NotificationActorDto {
  final String id;
  final String username;
  final String? avatarUrl;

  const NotificationActorDto({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory NotificationActorDto.fromJson(Map<String, dynamic> json) =>
      NotificationActorDto(
        id: _string(
          json['id'] ??
              json['_id'] ??
              json['userId'] ??
              json['actorId'] ??
              json['senderId'] ??
              json['fromUserId'],
        ),
        username: _string(
          json['username'] ??
              json['userName'] ??
              json['displayName'] ??
              json['name'],
        ),
        avatarUrl: _nullableString(json['avatarUrl'] ?? json['avatar_url']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}

class NotificationDto {
  final String id;
  final String type;
  final NotificationActorDto? actor;
  final String? referenceType;
  final String? referenceId;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationDto({
    required this.id,
    required this.type,
    this.actor,
    this.referenceType,
    this.referenceId,
    required this.message,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final actorJson = _mapOrNull(
      json['actor'] ?? json['user'] ?? json['sender'] ?? json['fromUser'],
    );
    final type = _string(json['type'] ?? json['notificationType']);
    final normalizedType = _normalizedType(type);

    return NotificationDto(
      id: _string(json['id'] ?? json['_id']),
      type: type,
      actor: actorJson != null
          ? NotificationActorDto.fromJson(actorJson)
          : _actorFromFlatJson(json),
      referenceType: _referenceTypeFor(json, normalizedType),
      referenceId: _referenceIdFor(json, normalizedType),
      message: _string(json['message'] ?? json['body'] ?? json['text']),
      isRead: _bool(json['isRead'] ?? json['is_read'] ?? json['read']),
      readAt: _dateOrNull(json['readAt'] ?? json['read_at']),
      createdAt:
          _dateOrNull(json['createdAt'] ?? json['created_at']) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (actor != null) 'actor': actor!.toJson(),
    'referenceType': referenceType,
    'referenceId': referenceId,
    'message': message,
    'isRead': isRead,
    if (readAt != null) 'readAt': readAt!.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };
}

String _normalizedType(String raw) {
  return raw
      .trim()
      .replaceAll('-', '_')
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])[A-Z]'),
        (match) => '_${match.group(0)}',
      )
      .toLowerCase();
}

NotificationActorDto? _actorFromFlatJson(Map<String, dynamic> json) {
  final id = _nullableString(
    json['actorId'] ?? json['senderId'] ?? json['fromUserId'] ?? json['userId'],
  );
  if (id == null) return null;

  return NotificationActorDto(
    id: id,
    username: _string(
      json['actorUsername'] ??
          json['actorName'] ??
          json['senderUsername'] ??
          json['senderName'] ??
          json['fromUserName'] ??
          json['username'] ??
          id,
    ),
    avatarUrl: _nullableString(
      json['actorAvatarUrl'] ??
          json['senderAvatarUrl'] ??
          json['fromUserAvatarUrl'] ??
          json['avatarUrl'],
    ),
  );
}

String? _referenceTypeFor(Map<String, dynamic> json, String type) {
  final hasTrackReference = _findTrackId(json) != null;
  if (hasTrackReference &&
      (type == 'track_commented' ||
          type == 'track_liked' ||
          type == 'track_reposted' ||
          type == 'new_release')) {
    return 'track';
  }

  final explicit = _nullableString(
    json['referenceType'] ??
        json['reference_type'] ??
        json['targetType'] ??
        json['entityType'] ??
        json['resourceType'],
  );
  if (explicit != null) return _normalizedReferenceType(explicit);

  if (hasTrackReference) return 'track';
  if (_findUserId(json) != null || type == 'user_followed') return 'user';
  return null;
}

String? _referenceIdFor(Map<String, dynamic> json, String type) {
  if (type == 'track_commented' ||
      type == 'track_liked' ||
      type == 'track_reposted' ||
      type == 'new_release') {
    final trackId = _findTrackId(json);
    if (trackId != null) return trackId;
  }

  if (type == 'user_followed') {
    final userId = _findUserId(json);
    if (userId != null) return userId;
  }

  return _nullableString(
    json['referenceId'] ??
        json['reference_id'] ??
        json['targetId'] ??
        json['entityId'] ??
        json['resourceId'] ??
        json['objectId'] ??
        json['object_id'] ??
        json['relatedId'] ??
        json['related_id'],
  );
}

String _normalizedReferenceType(String raw) {
  final text = raw.trim().split('.').last;
  return text
      .replaceAll('-', '_')
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])[A-Z]'),
        (match) => '_${match.group(0)}',
      )
      .toLowerCase();
}

String? _findTrackId(Map<String, dynamic> json) {
  final direct = _nullableString(
    json['trackId'] ??
        json['track_id'] ??
        json['songId'] ??
        json['song_id'] ??
        json['audioId'] ??
        json['audio_id'] ??
        json['postId'] ??
        json['post_id'] ??
        json['contentId'] ??
        json['content_id'] ??
        json['itemId'] ??
        json['item_id'] ??
        json['mediaId'] ??
        json['media_id'] ??
        json['musicId'] ??
        json['music_id'] ??
        json['uploadId'] ??
        json['upload_id'] ??
        json['objectId'] ??
        json['object_id'] ??
        json['relatedId'] ??
        json['related_id'] ??
        json['targetTrackId'] ??
        json['target_track_id'] ??
        json['referenceTrackId'] ??
        json['reference_track_id'],
  );
  if (direct != null) return direct;

  for (final key in const [
    'track',
    'target',
    'reference',
    'resource',
    'entity',
    'metadata',
    'meta',
    'payload',
    'data',
    'extra',
    'details',
    'context',
    'comment',
  ]) {
    final nested = _mapOrNull(json[key]);
    if (nested == null) continue;
    final nestedId = _nullableString(
      nested['trackId'] ?? nested['track_id'] ?? nested['id'] ?? nested['_id'],
    );
    if (nestedId != null &&
        (key == 'track' ||
            nested['type']?.toString().toLowerCase().contains('track') ==
                true ||
            nested.containsKey('trackId') ||
            nested.containsKey('track_id'))) {
      return nestedId;
    }
    final recursive = _findTrackId(nested);
    if (recursive != null) return recursive;
  }

  return null;
}

String? _findUserId(Map<String, dynamic> json) {
  final direct = _nullableString(
    json['userId'] ??
        json['user_id'] ??
        json['actorId'] ??
        json['senderId'] ??
        json['fromUserId'] ??
        json['referenceUserId'] ??
        json['targetUserId'],
  );
  if (direct != null) return direct;

  for (final key in const [
    'actor',
    'user',
    'sender',
    'fromUser',
    'target',
    'reference',
    'resource',
    'entity',
    'metadata',
    'meta',
    'payload',
    'data',
  ]) {
    final nested = _mapOrNull(json[key]);
    if (nested == null) continue;
    final nestedId = _nullableString(
      nested['userId'] ?? nested['user_id'] ?? nested['id'] ?? nested['_id'],
    );
    if (nestedId != null &&
        (key == 'user' ||
            key == 'actor' ||
            key == 'sender' ||
            key == 'fromUser' ||
            nested['type']?.toString().toLowerCase().contains('user') == true ||
            nested.containsKey('userId') ||
            nested.containsKey('user_id'))) {
      return nestedId;
    }
    final recursive = _findUserId(nested);
    if (recursive != null) return recursive;
  }

  return null;
}

class NotificationPreferencesDto {
  final Map<String, bool> push;
  final Map<String, bool> email;

  const NotificationPreferencesDto({required this.push, required this.email});

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDto(
      push: _parseBoolMap(json['push']),
      email: _parseBoolMap(json['email']),
    );
  }

  static Map<String, bool> _parseBoolMap(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), v == true));
  }
}

String _string(Object? value) => value?.toString() ?? '';

String? _nullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

bool _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1';
}

DateTime? _dateOrNull(Object? value) {
  if (value is DateTime) return value;
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

Map<String, dynamic>? _mapOrNull(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}
