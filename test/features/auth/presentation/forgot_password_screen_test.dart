/// Widget tests for [ForgotPasswordScreen].
///
/// Covers:
///   Submitting a non-existent email navigates to ResetPasswordScreen
///            (never reveals whether the email exists — security requirement).
///   Valid email navigates to ResetPasswordScreen.
///   Email validation — "Send reset link" button is disabled for invalid email.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/screens/forgot_password_screen.dart';

import '../../../helpers/mocks.mocks.dart';
import '../helpers/auth_selectors.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<void> pumpScreen(
  WidgetTester tester, {
  required MockAuthRepository mockRepo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: const ForgotPasswordScreen(),
        routes: {
          '/reset-password': (_) =>
              const Scaffold(body: Text('ResetPasswordScreen')),
        },
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── always navigate to reset screen ─────────────────────

  testWidgets('valid email navigates to ResetPasswordScreen', (tester) async {
    when(mockRepo.forgotPassword('user@example.com')).thenAnswer((_) async {});

    await pumpScreen(tester, mockRepo: mockRepo);

    await tester.enterText(
      AuthFinders.forgotPasswordEmailField,
      'user@example.com',
    );
    await tester.pump();
    await tester.tap(AuthFinders.sendResetLinkButton);
    await tester.pumpAndSettle();

    expect(find.text('ResetPasswordScreen'), findsOneWidget);
  });

  testWidgets('non-existent email still navigates (never reveals existence)', (
    tester,
  ) async {
    // forgotPassword swallows not-found — never throws to the UI.
    when(mockRepo.forgotPassword('ghost@example.com')).thenAnswer((_) async {});

    await pumpScreen(tester, mockRepo: mockRepo);

    await tester.enterText(
      AuthFinders.forgotPasswordEmailField,
      'ghost@example.com',
    );
    await tester.pump();
    await tester.tap(AuthFinders.sendResetLinkButton);
    await tester.pumpAndSettle();

    // Must navigate regardless — security spec says never reveal email existence.
    expect(find.text('ResetPasswordScreen'), findsOneWidget);
  });

  // ── Email validation: invalid input prevents navigation ───────────────────

  testWidgets('Send reset link button is disabled for invalid email', (
    tester,
  ) async {
    await pumpScreen(tester, mockRepo: mockRepo);

    await tester.enterText(AuthFinders.forgotPasswordEmailField, 'notanemail');
    await tester.pump();

    // Tapping must not navigate — form validation blocks submission.
    await tester.tap(AuthFinders.sendResetLinkButton);
    await tester.pumpAndSettle();

    expect(find.text('ResetPasswordScreen'), findsNothing);
  });
}
