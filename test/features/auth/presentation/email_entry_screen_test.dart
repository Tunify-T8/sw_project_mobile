/// Widget tests for [EmailEntryScreen].
///
/// Covers:
///   Continue button is disabled when email is empty or invalid format.
///   Continue button is enabled for a valid email; navigation to
///             PasswordScreen occurs when checkEmail returns true (existing).
///   Reject registration with empty email (button stays disabled).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:software_project/features/auth/presentation/screens/email_entry_screen.dart';

import '../../../helpers/mocks.mocks.dart';
import '../helpers/auth_selectors.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Pumps [EmailEntryScreen] inside a [ProviderScope] with a mocked controller.
Future<void> pumpScreen(
  WidgetTester tester, {
  required MockAuthRepository mockRepo,
  String mode = 'create',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
      child: MaterialApp(
        home: EmailEntryScreen(mode: mode),
        routes: {
          '/password': (_) => const Scaffold(body: Text('PasswordScreen')),
          '/register-detail': (_) =>
              const Scaffold(body: Text('RegisterDetailScreen')),
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

  // ── button disabled on empty / invalid email ─────────────

  group('Continue button — disabled states', () {
    testWidgets('is disabled when email field is empty', (tester) async {
      await pumpScreen(tester, mockRepo: mockRepo);

      // No text entered — button must be null (disabled).
      final button = tester.widget<ElevatedButton>(
        find.descendant(
          of: AuthFinders.emailEntryContinueButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('is disabled for invalid email formats', (tester) async {
      await pumpScreen(tester, mockRepo: mockRepo);

      for (final bad in ['notanemail', 'missing@', '@nodomain', '   ']) {
        await tester.enterText(AuthFinders.emailEntryField, bad);
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.descendant(
            of: AuthFinders.emailEntryContinueButton,
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(
          button.onPressed,
          isNull,
          reason: '"$bad" should keep the button disabled',
        );
      }
    });
  });

  // ── button enabled and navigates for existing email ───────────────

  group('Continue button — enabled state and navigation', () {
    testWidgets('is enabled once a valid email is typed', (tester) async {
      await pumpScreen(tester, mockRepo: mockRepo);

      await tester.enterText(AuthFinders.emailEntryField, 'valid@example.com');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.descendant(
          of: AuthFinders.emailEntryContinueButton,
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
      'navigates to PasswordScreen when checkEmail returns true (existing)',
      (tester) async {
        when(
          mockRepo.checkEmail('existing@example.com'),
        ).thenAnswer((_) async => true);

        await pumpScreen(tester, mockRepo: mockRepo, mode: 'login');

        await tester.enterText(
          AuthFinders.emailEntryField,
          'existing@example.com',
        );
        await tester.pump();
        await tester.tap(AuthFinders.emailEntryContinueButton);
        await tester.pumpAndSettle();

        expect(find.text('PasswordScreen'), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to RegisterDetailScreen when checkEmail returns false (new)',
      (tester) async {
        when(
          mockRepo.checkEmail('new@example.com'),
        ).thenAnswer((_) async => false);

        await pumpScreen(tester, mockRepo: mockRepo, mode: 'create');

        await tester.enterText(AuthFinders.emailEntryField, 'new@example.com');
        await tester.pump();
        await tester.tap(AuthFinders.emailEntryContinueButton);
        await tester.pumpAndSettle();

        expect(find.text('RegisterDetailScreen'), findsOneWidget);
      },
    );
  });
}
