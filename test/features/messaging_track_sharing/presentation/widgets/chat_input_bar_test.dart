import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/domain/entities/message_limits.dart';
import 'package:software_project/features/messaging_track_sharing/presentation/widgets/chat_input_bar.dart';

void main() {
  testWidgets('limits composer text to 20,000 characters', (tester) async {
    String? sentText;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatInputBar(
            onAttachTap: () {},
            onSend: (text) => sentText = text,
          ),
        ),
      ),
    );

    final longText = List.filled(kMaxMessageTextLength + 1, 'a').join();

    await tester.enterText(find.byType(TextField), longText);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(sentText, isNotNull);
    expect(sentText!.length, kMaxMessageTextLength);
  });
}
