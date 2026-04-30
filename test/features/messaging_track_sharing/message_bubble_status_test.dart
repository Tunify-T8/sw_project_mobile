import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_entity.dart';
import 'package:software_project/features/messaging_track_sharing/presentation/widgets/message_buble.dart';

void main() {
  testWidgets('shows only Sending for a pending outgoing message', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_message(isPending: true)));

    expect(find.text('Sending'), findsOneWidget);
    expect(find.text('Sent'), findsNothing);
    expect(find.text('Delivered'), findsNothing);
    expect(find.text('Seen'), findsNothing);
    expect(find.text('Not delivered'), findsNothing);
  });

  testWidgets('hides completed and failed delivery labels', (tester) async {
    for (final message in [
      _message(deliveryStatus: MessageDeliveryStatus.sent),
      _message(deliveryStatus: MessageDeliveryStatus.delivered),
      _message(deliveryStatus: MessageDeliveryStatus.read),
      _message(isFailed: true),
    ]) {
      await tester.pumpWidget(_harness(message));

      expect(find.text('Sending'), findsNothing);
      expect(find.text('Sent'), findsNothing);
      expect(find.text('Delivered'), findsNothing);
      expect(find.text('Seen'), findsNothing);
      expect(find.text('Not delivered'), findsNothing);
    }
  });
}

Widget _harness(MessageEntity message) {
  return MaterialApp(
    home: Scaffold(
      body: MessageBubble(message: message, isMine: true, showStatus: true),
    ),
  );
}

MessageEntity _message({
  MessageDeliveryStatus deliveryStatus = MessageDeliveryStatus.sent,
  bool isPending = false,
  bool isFailed = false,
}) {
  return MessageEntity(
    id: 'message-1',
    conversationId: 'conversation-1',
    senderId: 'youssef',
    type: MessageType.text,
    text: 'hii',
    createdAt: DateTime.utc(2026, 4, 30, 10),
    deliveryStatus: deliveryStatus,
    isPending: isPending,
    isFailed: isFailed,
  );
}
