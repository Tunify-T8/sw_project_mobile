import 'package:flutter/material.dart';
import 'package:software_project/features/auth/presentation/screens/splash_screen.dart';
import 'package:software_project/features/auth/presentation/screens/landing_screen.dart';
import 'package:software_project/features/auth/presentation/screens/sign_in_or_create_screen.dart';
import 'package:software_project/features/auth/presentation/screens/email_entry_screen.dart';
import 'package:software_project/features/auth/presentation/screens/password_screen.dart';
import 'package:software_project/features/auth/presentation/screens/register_detail_screen.dart';
import 'package:software_project/features/auth/presentation/screens/tell_us_more_screen.dart';
import 'package:software_project/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:software_project/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:software_project/features/auth/presentation/screens/check_your_email_screen.dart';
import 'package:software_project/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:software_project/features/auth/presentation/screens/delete_account_screen.dart';
import 'package:software_project/features/auth/presentation/screens/account_screen.dart';

/// Named route path constants.
/// All navigation must use these — never hard-code route strings.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String landing = '/landing';
  static const String signInOrCreate = '/sign-in';

  /// Email entry sub-screen (image 4) — shown after tapping "Or with email".
  static const String emailEntry = '/email-entry';

  /// Login path — password entry for an existing account.
  static const String password = '/password';

  /// Register path — password creation for a new account.
  static const String registerDetail = '/register-detail';

  /// Profile details — display name, DOB, gender.
  static const String tellUsMore = '/tell-us-more';

  /// Email verification — 6-char token entry.
  static const String verifyEmail = '/verify-email';

  static const String forgotPassword = '/forgot-password';
  static const String checkYourEmail = '/check-your-email';
  static const String resetPassword = '/reset-password';

  /// Account screen — email, sign out, delete account link.
  static const String account = '/account';

  static const String deleteAccount = '/delete-account';

  /// Home screen — implemented by another module.
  static const String home = '/home';
}

/// Generates the [Route] for each named route.
/// All arguments are [Map<String, dynamic>] via [RouteSettings.arguments].
Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>? ?? {};

  switch (settings.name) {
    case AppRoutes.splash:
      return _fade(const SplashScreen(), settings);

    case AppRoutes.landing:
      return _fade(const LandingScreen(), settings);

    case AppRoutes.signInOrCreate:
      return _fade(
        SignInOrCreateScreen(initialMode: args['mode'] as String?),
        settings,
      );

    case AppRoutes.emailEntry:
      return _fade(
        EmailEntryScreen(
          initialEmail: args['email'] as String?,
          mode: args['mode'] as String? ?? 'create',
        ),
        settings,
      );

    case AppRoutes.password:
      return _fade(
        PasswordScreen(
          email: args['email'] as String? ?? '',
          showAccountExistsNotice:
              args['showAccountExistsNotice'] as bool? ?? false,
        ),
        settings,
      );

    case AppRoutes.registerDetail:
      return _fade(
        RegisterDetailScreen(email: args['email'] as String? ?? ''),
        settings,
      );

    case AppRoutes.tellUsMore:
      return _fade(
        TellUsMoreScreen(
          email: args['email'] as String? ?? '',
          password: args['password'] as String? ?? '',
        ),
        settings,
      );

    case AppRoutes.verifyEmail:
      return _fade(
        VerifyEmailScreen(email: args['email'] as String? ?? ''),
        settings,
      );

    case AppRoutes.forgotPassword:
      return _fade(
        ForgotPasswordScreen(initialEmail: args['email'] as String?),
        settings,
      );

    case AppRoutes.checkYourEmail:
      return _fade(
        CheckYourEmailScreen(email: args['email'] as String? ?? ''),
        settings,
      );

    case AppRoutes.resetPassword:
      return _fade(
        ResetPasswordScreen(
          email: args['email'] as String?,
          resetToken: args['token'] as String?,
        ),
        settings,
      );

    case AppRoutes.account:
      return _fade(const AccountScreen(), settings);

    case AppRoutes.deleteAccount:
      return _fade(const DeleteAccountScreen(), settings);

    case AppRoutes.home:
      // TODO: Replace Placeholder with HomeScreen once implemented.
      return _fade(const Placeholder(), settings);

    default:
      return _fade(const Placeholder(), settings);
  }
}

/// 300 ms fade transition used for all route changes.
PageRouteBuilder<dynamic> _fade(Widget page, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}
