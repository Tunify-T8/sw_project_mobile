/// Widget tests for [PasswordScreen].
///
/// Covers:
///   Sign in successfully with valid credentials → navigates to home.
///   Sign-in with wrong password → shows error snackbar, stays on screen.
///   Unverified user login → navigates to VerifyEmailScreen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/core/errors/failure.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/screens/password_screen.dart';

import '../../../helpers/mocks.mocks.dart';
import '../helpers/auth_selectors.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const tUser = AuthUserEntity(
  id: 'u1',
  email: 'user@example.com',
  username: 'tester',
  role: 'ARTIST',
  isVerified: true,
);

Future<void> pumpScreen(
  WidgetTester tester, {
  required MockAuthRepository mockRepo,
  bool showAccountExistsNotice = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: PasswordScreen(
          email: 'user@example.com',
          showAccountExistsNotice: showAccountExistsNotice,
        ),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HomeScreen')),
          '/verify-email': (_) =>
              const Scaffold(body: Text('VerifyEmailScreen')),
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

  // ── valid credentials → home ─────────────────────────────────────

  testWidgets('valid credentials navigate to HomeScreen', (tester) async {
    when(
      mockRepo.login('user@example.com', 'ValidPass1!'),
    ).thenAnswer((_) async => tUser);

    await pumpScreen(tester, mockRepo: mockRepo);

    await tester.enterText(
      find.byKey(AuthKeys.loginPasswordField),
      'ValidPass1!',
    );
    await tester.pump();
    await tester.tap(find.byKey(AuthKeys.loginContinueButton));
    await tester.pumpAndSettle();

    expect(find.text('HomeScreen'), findsOneWidget);
  });

  // ── wrong password → error snackbar ───────────────────────────────

  testWidgets('wrong password shows error snackbar', (tester) async {
    when(
      mockRepo.login('user@example.com', 'WrongPass1!'),
    ).thenThrow(const UnauthorizedFailure());

    await pumpScreen(tester, mockRepo: mockRepo);

    await tester.enterText(
      find.byKey(AuthKeys.loginPasswordField),
      'WrongPass1!',
    );
    await tester.pump();
    await tester.tap(find.byKey(AuthKeys.loginContinueButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
    // Screen should still be visible (not navigated away).
    expect(find.byType(PasswordScreen), findsOneWidget);
  });

  // ── unverified user → VerifyEmailScreen ───────────────────────────

  testWidgets('unverified user redirected to VerifyEmailScreen', (
    tester,
  ) async {
    when(
      mockRepo.login('user@example.com', 'ValidPass1!'),
    ).thenThrow(const UnverifiedUserFailure());

    await pumpScreen(tester, mockRepo: mockRepo);

    await tester.enterText(
      find.byKey(AuthKeys.loginPasswordField),
      'ValidPass1!',
    );
    await tester.pump();
    await tester.tap(find.byKey(AuthKeys.loginContinueButton));
    await tester.pumpAndSettle();

    expect(find.text('VerifyEmailScreen'), findsOneWidget);
  });

  // ── showAccountExistsNotice banner ────────────────────────────────────────

  testWidgets(
    'shows "account already exists" banner when notice flag is true',
    (tester) async {
      await pumpScreen(
        tester,
        mockRepo: mockRepo,
        showAccountExistsNotice: true,
      );

      // The banner text is hard-coded in PasswordScreen.
      expect(find.textContaining('account already exists'), findsOneWidget);
    },
  );
}
