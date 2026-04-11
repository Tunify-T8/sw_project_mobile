import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/feed_search_discovery/presentation/widgets/search/search_bar_widget.dart';

void main() {
  testWidgets('shows back button and triggers callbacks', (tester) async {
    final controller = TextEditingController(text: 'rock');
    final focusNode = FocusNode();
    var backTapped = false;
    var cleared = false;
    String? changed;
    String? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SearchBarWidget(
            controller: controller,
            focusNode: focusNode,
            showBackButton: true,
            onBack: () => backTapped = true,
            onChanged: (value) => changed = value,
            onSubmitted: (value) => submitted = value,
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.enterText(find.byType(TextField), 'pop');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(backTapped, isTrue);
    expect(cleared, isTrue);
    expect(changed, 'pop');
    expect(submitted, 'pop');
  });

  testWidgets('hides clear icon when controller is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SearchBarWidget(
            controller: TextEditingController(),
            focusNode: FocusNode(),
            onChanged: (_) {},
            onSubmitted: (_) {},
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.cancel), findsNothing);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });
}
