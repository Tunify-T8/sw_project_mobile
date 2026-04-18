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
        id: json['id'] as String,
        username: json['username'] as String,
        avatarUrl: json['avatarUrl'] as String?,
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

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      NotificationDto(
        id: json['id'] as String,
        type: json['type'] as String,
        actor: json['actor'] != null
            ? NotificationActorDto.fromJson(
                json['actor'] as Map<String, dynamic>)
            : null,
        referenceType: json['referenceType'] as String?,
        referenceId: json['referenceId'] as String?,
        message: json['message'] as String,
        isRead: json['isRead'] as bool? ?? false,
        readAt: json['readAt'] != null
            ? DateTime.parse(json['readAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

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

  const NotificationPreferencesDto({
    required this.push,
    required this.email,
  });

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
