import 'package:flutter/material.dart';
/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );*/ import 'package:flutter/material.dart';

import '../core/routing/routes.dart';
import '../features/audio_upload_and_management/domain/entities/upload_item.dart';
import '../features/audio_upload_and_management/presentation/screens/edit_track_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/track_metadata_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/upload_entry_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/upload_progress_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/your_uploads_screen.dart';

import '../features/auth/presentation/screens/account_screen.dart';
import '../features/auth/presentation/screens/check_your_email_screen.dart';
import '../features/auth/presentation/screens/delete_account_screen.dart';
import '../features/auth/presentation/screens/email_entry_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/landing_screen.dart';
import '../features/auth/presentation/screens/password_screen.dart';
import '../features/auth/presentation/screens/register_detail_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/sign_in_or_create_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/tell_us_more_screen.dart';
import '../features/auth/presentation/screens/verify_email_screen.dart';

import 'main_shell_screen.dart';
import 'route_guards.dart';

/// Auth route names.
/// Keep this because the auth module will already be using these names.
class AppRoutes {
  AppRoutes._();

  static const String authGate = '/';
  static const String splash = '/splash';
  static const String landing = '/landing';
  static const String signInOrCreate = '/sign-in';
  static const String emailEntry = '/email-entry';
  static const String password = '/password';
  static const String registerDetail = '/register-detail';
  static const String tellUsMore = '/tell-us-more';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String checkYourEmail = '/check-your-email';
  static const String resetPassword = '/reset-password';
  static const String account = '/account';
  static const String deleteAccount = '/delete-account';

  /// After auth succeeds, go to your app shell.
  static const String home = '/home';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = _readArgs(settings.arguments);

    switch (settings.name) {
      // ---------------- AUTH FLOW ----------------
      case AppRoutes.authGate:
        return _fade(const AuthGate(), settings);

      case AppRoutes.splash:
        return _fade(
          SplashScreen(
            destination: args['destination'] as String? ?? AppRoutes.landing,
          ),
          settings,
        );

      case AppRoutes.landing:
        return _fade(const LandingScreen(), settings);

      case AppRoutes.signInOrCreate:
        return _fade(
          SignInOrCreateScreen(
            initialMode: args['mode'] as String?,
          ),
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
          RegisterDetailScreen(
            email: args['email'] as String? ?? '',
          ),
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
          VerifyEmailScreen(
            email: args['email'] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.forgotPassword:
        return _fade(
          ForgotPasswordScreen(
            initialEmail: args['email'] as String?,
          ),
          settings,
        );

      case AppRoutes.checkYourEmail:
        return _fade(
          CheckYourEmailScreen(
            email: args['email'] as String? ?? '',
          ),
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

      /// Auth branch wanted "home" here.
      /// We map it to your real app shell.
      case AppRoutes.home:
      case Routes.shell:
        return _fade(const MainShellScreen(), settings);

      // ---------------- YOUR UPLOAD / LIBRARY FLOW ----------------
      case Routes.uploadEntry:
        return _slide(const UploadEntryScreen(), settings);

      case Routes.trackMetadata:
        return _slide(
          TrackMetadataScreen(
            trackId: args['trackId'] as String? ?? '',
            fileName: args['fileName'] as String? ?? '',
          ),
          settings,
        );

      case Routes.uploadProgress:
        return _slide(const UploadProgressScreen(), settings);

      case Routes.editTrack:
        final item = settings.arguments as UploadItem;
        return _slide(EditTrackScreen(item: item), settings);

      case Routes.trackDetail:
        final item = settings.arguments as UploadItem;
        return _slide(TrackDetailScreen(item: item), settings);

      case Routes.yourUploads:
        return _slide(const YourUploadsScreen(), settings);

      default:
        return _fade(const MainShellScreen(), settings);
    }
  }

  static Map<String, dynamic> _readArgs(Object? rawArgs) {
    if (rawArgs is Map) {
      return rawArgs.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  static PageRouteBuilder<T> _fade<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<T> _slide<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(
          CurveTween(curve: Curves.ease),
        ).animate(animation),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

}
