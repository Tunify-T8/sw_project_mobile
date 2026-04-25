/// Input validators for all authentication forms.
///
/// ── USAGE ────────────────────────────────────────────────────────────────────
/// Returns `null` for valid input, a human-readable error string for invalid.
/// Every method is compatible with Flutter's [FormField.validator] directly:
/// ```dart
/// AppTextField(validator: Validators.email)
/// AppTextField(validator: Validators.password)
/// AppTextField(validator: Validators.username)
/// ```
///
/// ── ADDING NEW VALIDATORS ────────────────────────────────────────────────────
/// Add only pure static methods here — no state, no imports from Flutter.
/// Each method must: return `null` on valid, return a non-null string on
/// invalid, and cover the null/empty case explicitly.
class Validators {
  Validators._();

  // ── Email ──────────────────────────────────────────────────────────────────

  /// Validates an email address format.
  ///
  /// Returns `null` when the format matches `x@y.z`, an error string
  /// for null, empty, or malformed input.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ── Passwords ──────────────────────────────────────────────────────────────

  /// Validates a password for account creation or reset.
  ///
  /// Backend requirements (enforced here so errors appear inline before
  /// the network call):
  ///   - Minimum 8 characters
  ///   - At least one uppercase letter
  ///   - At least one lowercase letter
  ///   - At least one digit
  ///   - At least one special character from `!@#$%^&*(),.?":{}|<>`
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Login password — existence check only (server validates correctness).
  ///
  /// Intentionally lenient: any non-empty value is accepted here. The
  /// backend returns [UnauthorizedFailure] if the password is wrong.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  /// Validates that [value] matches [original] exactly.
  ///
  /// Used for the "Confirm password" field. Pass the new password as
  /// [original].
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  // ── Username (handle) ─────────────────────────────────────────────────────

  /// Validates a username / handle sent to the backend as `username`.
  ///
  /// Backend rule (enforced at `/auth/register`):
  ///   "Username can only contain letters, numbers, and underscores"
  ///
  /// Additional client-side rules:
  ///   - Minimum 2 characters (matches [displayName] minimum)
  ///   - Maximum 30 characters (reasonable handle length)
  ///   - No leading or trailing underscores
  ///
  /// This is distinct from [displayName], which allows spaces and is shown
  /// on the profile. [username] is the unique handle used for login and URLs.
  ///
  /// Example valid: `robin_banks`, `RobinBanks`, `user123`
  /// Example invalid: `Robin Banks` (space), `robin-banks` (hyphen),
  ///                  `_robin` (leading underscore)
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a username';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Username must be at least 2 characters';
    }
    if (trimmed.length > 30) {
      return 'Username must be 30 characters or fewer';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    if (trimmed.startsWith('_') || trimmed.endsWith('_')) {
      return 'Username cannot start or end with an underscore';
    }
    return null;
  }

  // ── Display name ───────────────────────────────────────────────────────────

  /// Validates a display name shown on the user's public profile.
  ///
  /// More permissive than [username] — spaces and most Unicode characters
  /// are allowed because this is a human-readable name, not a handle.
  /// The backend stores this separately as `displayName`.
  ///
  /// Rules:
  ///   - Minimum 2 characters (after trimming)
  ///   - No further restrictions (server handles Unicode/emoji edge cases)
  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a display name';
    }
    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }
    return null;
  }

  // ── Verification token ────────────────────────────────────────────────────

  /// Validates a 6-character email verification or password-reset token.
  ///
  /// Returns `null` for exactly 6 non-whitespace characters, an error
  /// string otherwise.
  static String? verificationToken(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the verification code';
    }
    if (value.trim().length != 6) {
      return 'The code must be exactly 6 characters';
    }
    return null;
  }

  // ── Generic ────────────────────────────────────────────────────────────────

  /// Generic required-field validator.
  ///
  /// Returns `null` when [value] is non-empty after trimming.
  /// Pass [fieldName] for a specific error message, e.g. `'Email'`.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
