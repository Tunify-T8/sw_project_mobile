import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/notifications/domain/entities/notification_type.dart';

void main() {
  test('maps message aliases to newMessage', () {
    expect(NotificationType.fromString('message'), NotificationType.newMessage);
    expect(
      NotificationType.fromString('new_message'),
      NotificationType.newMessage,
    );
    expect(
      NotificationType.fromString('newMessage'),
      NotificationType.newMessage,
    );
  });
}
