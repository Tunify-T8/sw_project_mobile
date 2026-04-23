/// Widget tests for [RegisterDetailScreen].
///
/// Covers:
///   Continue button is disabled when password is weak/too-short.
///   Continue button is disabled when password field is empty.
///   Continue button is enabled when password is valid AND captcha checked.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/auth/presentation/screens/register_detail_screen.dart';

import '../helpers/auth_selectors.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Pumps [RegisterDetailScreen] in isolation (no Riverpod needed — screen
/// only calls the controller on navigation, not on build).
Future<void> pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RegisterDetailScreen(email: 'test@example.com'),
      routes: {
        '/tell-us-more': (_) => const Scaffold(body: Text('TellUsMoreScreen')),
      },
    ),
  );
}

/// Returns the [onPressed] value of the Continue ElevatedButton.
VoidCallback? _continueOnPressed(WidgetTester tester) {
  // AppButton wraps ElevatedButton — find by key then get the inner button.
  final buttonFinder = find.descendant(
    of: AuthFinders.registerContinueButton,
    matching: find.byType(ElevatedButton),
  );
  if (tester.any(buttonFinder)) {
    return tester.widget<ElevatedButton>(buttonFinder).onPressed;
  }
  // AppButton itself may BE the ElevatedButton when no descendant wraps it.
  return tester
      .widget<ElevatedButton>(AuthFinders.registerContinueButton)
      .onPressed;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── empty password keeps button disabled ──────────────────────────

  testWidgets('button disabled when password field is empty', (tester) async {
    await pumpScreen(tester);
    // Nothing typed yet — button must be null.
    expect(_continueOnPressed(tester), isNull);
  });

  // ── weak / short passwords keep button disabled ──────────────────

  group('button disabled for invalid passwords', () {
    final weakPasswords = [
      'short', // too short
      'alllowercase1!', // no uppercase
      'ALLUPPERCASE1!', // no lowercase
      'NoSpecialChar1', // no special character
      'NoNumber!Abc', // no digit
    ];

    for (final pw in weakPasswords) {
      testWidgets('disabled for "$pw"', (tester) async {
        await pumpScreen(tester);
        await tester.enterText(AuthFinders.registerPasswordField, pw);
        await tester.pump();
        expect(
          _continueOnPressed(tester),
          isNull,
          reason: '"$pw" is invalid — button should stay disabled',
        );
      });
    }
  });

  // ── valid password + captcha enables button ──────────────────────

  testWidgets(
    'button remains disabled with valid password but captcha unchecked',
    (tester) async {
      await pumpScreen(tester);
      await tester.enterText(AuthFinders.registerPasswordField, 'ValidPass1!');
      await tester.pump();
      // CAPTCHA not yet checked — still disabled.
      expect(_continueOnPressed(tester), isNull);
    },
  );

  testWidgets('button enabled when valid password AND captcha checked', (
    tester,
  ) async {
    await pumpScreen(tester);

    // 1. Enter a valid password.
    await tester.enterText(AuthFinders.registerPasswordField, 'ValidPass1!');
    await tester.pump();

    // 2. Check the mock CAPTCHA checkbox.
    await tester.tap(AuthFinders.captchaCheckbox);
    await tester.pump();

    // 3. Button must now be active.
    expect(_continueOnPressed(tester), isNotNull);
  });

  testWidgets(
    'tapping Continue with valid password + captcha navigates to TellUsMoreScreen',
    (tester) async {
      await pumpScreen(tester);

      await tester.enterText(AuthFinders.registerPasswordField, 'ValidPass1!');
      await tester.pump();
      await tester.tap(AuthFinders.captchaCheckbox);
      await tester.pump();
      await tester.tap(AuthFinders.registerContinueButton);
      await tester.pumpAndSettle();

      expect(find.text('TellUsMoreScreen'), findsOneWidget);
    },
  );
}
