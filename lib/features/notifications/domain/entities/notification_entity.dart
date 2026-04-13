import 'notification_actor.dart';
import 'notification_type.dart';

/// Domain model for a single notification record.
class NotificationEntity {
  final String id;
  final NotificationType type;
  final NotificationActor? actor;
  final String? referenceType;
  final String? referenceId;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationEntity({
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

  NotificationEntity copyWith({
    bool? isRead,
    DateTime? readAt,
  }) =>
      NotificationEntity(
        id: id,
        type: type,
        actor: actor,
        referenceType: referenceType,
        referenceId: referenceId,
        message: message,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
      );
}
