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
        id: _string(json['id'] ?? json['_id'] ?? json['userId']),
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

    return NotificationDto(
      id: _string(json['id'] ?? json['_id']),
      type: _string(json['type'] ?? json['notificationType']),
      actor: actorJson != null
          ? NotificationActorDto.fromJson(actorJson)
          : null,
      referenceType: _nullableString(
        json['referenceType'] ?? json['reference_type'] ?? json['targetType'],
      ),
      referenceId: _nullableString(
        json['referenceId'] ??
            json['reference_id'] ??
            json['targetId'] ??
            json['trackId'],
      ),
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
