import '../../domain/entities/notification_actor.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/entities/notification_type.dart';
import '../../domain/entities/paginated_notifications.dart';
import '../dto/notification_dto.dart';

class NotificationMapper {
  NotificationMapper._();

  static NotificationEntity notification(NotificationDto dto) =>
      NotificationEntity(
        id: dto.id,
        type: NotificationType.fromString(dto.type),
        actor: dto.actor != null ? _actor(dto.actor!) : null,
        referenceType: dto.referenceType,
        referenceId: dto.referenceId,
        message: dto.message,
        isRead: dto.isRead,
        readAt: dto.readAt,
        createdAt: dto.createdAt,
      );

  static NotificationActor _actor(NotificationActorDto dto) =>
      NotificationActor(
        id: dto.id,
        username: dto.username,
        avatarUrl: dto.avatarUrl,
      );

  static PaginatedNotifications paginatedFromJson(Map<String, dynamic> json) {
    final payload = _payload(json);
    final dataList = _dataList(payload);
    final meta = _map(payload['meta']);
    final items = dataList
        .map((e) => notification(NotificationDto.fromJson(_map(e))))
        .toList();

    return PaginatedNotifications(
      items: items,
      page: _int(meta['page']) ?? 1,
      limit: _int(meta['limit']) ?? 20,
      total: _int(meta['total']) ?? dataList.length,
      unreadCount:
          _int(meta['unreadCount'] ?? payload['unreadCount']) ??
          items.where((n) => !n.isRead).length,
    );
  }

  static NotificationPreferencesEntity preferences(
    NotificationPreferencesDto dto,
  ) => NotificationPreferencesEntity(
    push: _channel(dto.push),
    email: _channel(dto.email),
  );

  static PreferenceChannel _channel(Map<String, bool> map) => PreferenceChannel(
    trackLiked: map['trackLiked'] ?? true,
    trackCommented: map['trackCommented'] ?? true,
    trackReposted: map['trackReposted'] ?? true,
    userFollowed: map['userFollowed'] ?? true,
    newRelease: map['newRelease'] ?? true,
    newMessage: map['newMessage'] ?? true,
    system: map['system'] ?? true,
    subscription: map['subscription'] ?? true,
  );

  static Map<String, dynamic> _payload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    return json;
  }

  static List<dynamic> _dataList(Map<String, dynamic> json) {
    final raw = json['data'] ?? json['notifications'] ?? json['items'];
    if (raw is List) return raw;
    return const [];
  }

  static Map<String, dynamic> _map(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.map((k, v) => MapEntry(k.toString(), v));
    return const {};
  }

  static int? _int(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }
}
