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
    final dataList = (json['data'] as List<dynamic>?) ?? [];
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};

    return PaginatedNotifications(
      items: dataList
          .map((e) => notification(
              NotificationDto.fromJson(e as Map<String, dynamic>)))
          .toList(),
      page: (meta['page'] as int?) ?? 1,
      limit: (meta['limit'] as int?) ?? 20,
      total: (meta['total'] as int?) ?? dataList.length,
      unreadCount: (meta['unreadCount'] as int?) ?? 0,
    );
  }

  static NotificationPreferencesEntity preferences(
          NotificationPreferencesDto dto) =>
      NotificationPreferencesEntity(
        push: _channel(dto.push),
        email: _channel(dto.email),
      );

  static PreferenceChannel _channel(Map<String, bool> map) =>
      PreferenceChannel(
        trackLiked: map['trackLiked'] ?? true,
        trackCommented: map['trackCommented'] ?? true,
        trackReposted: map['trackReposted'] ?? true,
        userFollowed: map['userFollowed'] ?? true,
        newRelease: map['newRelease'] ?? true,
        newMessage: map['newMessage'] ?? true,
        system: map['system'] ?? true,
        subscription: map['subscription'] ?? true,
      );
}
