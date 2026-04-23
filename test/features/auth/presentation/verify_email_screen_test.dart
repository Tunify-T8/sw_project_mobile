/// Widget tests for [VerifyEmailScreen].
///
/// Covers:
///   M1-007  — Screen appears after an unverified login attempt (assert fix).
///             Verify button is disabled until all 6 digits are filled.
///   M1-002  — Verify button triggers verifyEmail; navigates home on success.
///   M1-008  — Resend button calls resendVerification.
///   M1-009  — Invalid/expired token shows error snackbar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/screens/verify_email_screen.dart';

import '../../../helpers/mocks.mocks.dart';
import '../helpers/auth_selectors.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const tUser = AuthUserEntity(
  id: 'u1',
  email: 'test@example.com',
  username: 'tester',
  role: 'ARTIST',
  isVerified: true,
);

Future<void> pumpScreen(
  WidgetTester tester, {
  required MockAuthRepository mockRepo,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: VerifyEmailScreen(email: 'test@example.com'),
        routes: {'/home': (_) => const Scaffold(body: Text('HomeScreen'))},
      ),
    ),
  );
}

/// Enters the 6-character [token] one digit at a time across the digit fields.
Future<void> enterToken(WidgetTester tester, String token) async {
  for (var i = 0; i < 6; i++) {
    await tester.enterText(AuthFinders.tokenDigitAt(i), token[i]);
    await tester.pump();
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── screen is identifiable after unverified login ─────────────────

  testWidgets('verify_email_title key is present on screen', (tester) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    // The Key on the title text lets tests assert the screen appeared.
    expect(AuthFinders.verifyEmailTitle, findsOneWidget);
  });

  // ── Verify button disabled until 6 digits entered ─────────────────────────

  testWidgets('Verify button is disabled when no digits are entered', (
    tester,
  ) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    final btn = tester.widget<ElevatedButton>(
      find.descendant(
        of: AuthFinders.verifyButton,
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(btn.onPressed, isNull);
  });

  testWidgets(
    'Verify button is disabled when fewer than 6 digits are entered',
    (tester) async {
      await pumpScreen(tester, mockRepo: mockRepo);
      // Enter only 5 digits.
      for (var i = 0; i < 5; i++) {
        await tester.enterText(AuthFinders.tokenDigitAt(i), 'A');
        await tester.pump();
      }
      final btn = tester.widget<ElevatedButton>(
        find.descendant(
          of: AuthFinders.verifyButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(btn.onPressed, isNull);
    },
  );

  testWidgets('Verify button is enabled once all 6 digits are filled', (
    tester,
  ) async {
    await pumpScreen(tester, mockRepo: mockRepo);
    await enterToken(tester, 'ABCDEF');
    final btn = tester.widget<ElevatedButton>(
      find.descendant(
        of: AuthFinders.verifyButton,
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(btn.onPressed, isNotNull);
  });

  // ── successful verification navigates home ────────────────────────

  testWidgets('valid token verifies and navigates to home', (tester) async {
    when(
      mockRepo.verifyEmail('test@example.com', 'ABC123'),
    ).thenAnswer((_) async => tUser);
    // saveSession is called internally by the repository.

    await pumpScreen(tester, mockRepo: mockRepo);
    await enterToken(tester, 'ABC123');
    await tester.tap(AuthFinders.verifyButton);
    await tester.pumpAndSettle();

    expect(find.text('HomeScreen'), findsOneWidget);
  });

  // ── invalid token shows error snackbar ────────────────────────────

  testWidgets('expired token shows error snackbar', (tester) async {
    when(
      mockRepo.verifyEmail('test@example.com', 'XXXXXX'),
    ).thenThrow(const UnauthorizedFailure());

    await pumpScreen(tester, mockRepo: mockRepo);
    await enterToken(tester, 'XXXXXX');
    await tester.tap(AuthFinders.verifyButton);
    await tester.pump(); // trigger state change
    await tester.pump(const Duration(seconds: 1)); // snackbar animation

    expect(find.byType(SnackBar), findsOneWidget);
  });

  // ── resend button calls resendVerification ────────────────────────

  testWidgets('tapping Resend calls resendVerification', (tester) async {
    when(
      mockRepo.resendVerification('test@example.com'),
    ).thenAnswer((_) async {});

    await pumpScreen(tester, mockRepo: mockRepo);
    await tester.tap(AuthFinders.resendCodeButton);
    await tester.pumpAndSettle();

    verify(mockRepo.resendVerification('test@example.com')).called(1);
  });
}
