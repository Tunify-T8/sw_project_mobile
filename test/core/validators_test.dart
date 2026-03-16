import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/core/utils/validators.dart';

/// Unit tests for [Validators].
///
/// No mocks needed — validators are pure functions.
/// Every public method is fully covered.
void main() {
  // ── email ──────────────────────────────────────────────────────────────────

  group('Validators.email', () {
    test('returns null for a standard valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain and tag', () {
      expect(Validators.email('user.name+tag@mail.domain.co.uk'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.email('   '), isNotNull);
    });

    test('returns error when @ is missing', () {
      expect(Validators.email('userexample.com'), isNotNull);
    });

    test('returns error when domain is missing after @', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('returns error when TLD is missing', () {
      expect(Validators.email('user@domain'), isNotNull);
    });
  });

  // ── password (registration — strict rules) ─────────────────────────────────

  group('Validators.password', () {
    test('returns null for a fully valid password', () {
      // Meets all rules: length ≥ 8, upper, lower, digit, special char
      expect(Validators.password('Secret1!'), isNull);
    });

    test('returns null for a long complex password', () {
      expect(Validators.password('MyP@ssw0rd123'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.password(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.password(''), isNotNull);
    });

    test('returns error when shorter than 8 characters', () {
      expect(Validators.password('Sec1!'), isNotNull);
    });

    test('returns error when no uppercase letter', () {
      expect(Validators.password('secret1!'), isNotNull);
    });

    test('returns error when no lowercase letter', () {
      expect(Validators.password('SECRET1!'), isNotNull);
    });

    test('returns error when no digit', () {
      expect(Validators.password('SecretPass!'), isNotNull);
    });

    test('returns error when no special character', () {
      expect(Validators.password('SecretPass1'), isNotNull);
    });
  });

  // ── loginPassword (presence only — no strength check) ─────────────────────

  group('Validators.loginPassword', () {
    test('returns null for any non-empty string', () {
      expect(Validators.loginPassword('x'), isNull);
    });

    test('returns null for a short password', () {
      expect(Validators.loginPassword('abc'), isNull);
    });

    test('returns null for a long password', () {
      expect(Validators.loginPassword('a very long password 123!'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.loginPassword(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.loginPassword(''), isNotNull);
    });

    // loginPassword only checks presence (value.isEmpty), not trimmed content.
    // Whitespace-only is allowed because the server validates correctness.
    test('returns null for whitespace-only (presence check only)', () {
      expect(Validators.loginPassword('   '), isNull);
    });
  });

  // ── confirmPassword ─────────────────────────────────────────────────────────

  group('Validators.confirmPassword', () {
    test('returns null when both values match', () {
      expect(Validators.confirmPassword('Secret1!', 'Secret1!'), isNull);
    });

    test('returns error when values differ', () {
      expect(Validators.confirmPassword('Secret1!', 'Different1!'), isNotNull);
    });

    test('returns error for null confirm field', () {
      expect(Validators.confirmPassword(null, 'Secret1!'), isNotNull);
    });

    test('returns error for empty confirm field', () {
      expect(Validators.confirmPassword('', 'Secret1!'), isNotNull);
    });
  });

  // ── displayName ─────────────────────────────────────────────────────────────

  group('Validators.displayName', () {
    test('returns null for a two-character name', () {
      expect(Validators.displayName('Jo'), isNull);
    });

    test('returns null for a normal full name', () {
      expect(Validators.displayName('Dani Saad'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.displayName(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.displayName(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.displayName('   '), isNotNull);
    });

    test('returns error for a single character', () {
      expect(Validators.displayName('A'), isNotNull);
    });
  });

  // ── verificationToken ───────────────────────────────────────────────────────

  group('Validators.verificationToken', () {
    test('returns null for exactly 6 alphanumeric characters', () {
      expect(Validators.verificationToken('ABC123'), isNull);
    });

    test('returns null for 6 lowercase letters', () {
      expect(Validators.verificationToken('abcdef'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.verificationToken(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.verificationToken(''), isNotNull);
    });

    test('returns error for fewer than 6 characters', () {
      expect(Validators.verificationToken('AB12'), isNotNull);
    });

    test('returns error for more than 6 characters', () {
      expect(Validators.verificationToken('ABC1234'), isNotNull);
    });
  });

  // ── required ─────────────────────────────────────────────────────────────────

  group('Validators.required', () {
    test('returns null for a non-empty value', () {
      expect(Validators.required('anything'), isNull);
    });

    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(Validators.required('  '), isNotNull);
    });

    test('error message includes custom fieldName when provided', () {
      final error = Validators.required('', fieldName: 'Email');
      expect(error, contains('Email'));
    });
  });
}
