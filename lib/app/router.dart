import 'package:flutter/material.dart';

import '../core/routing/routes.dart';
import '../features/audio_upload_and_management/domain/entities/upload_item.dart';
import '../features/audio_upload_and_management/presentation/screens/edit_track_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../features/audio_upload_and_management/presentation/utils/track_link_helper.dart';
import '../features/audio_upload_and_management/presentation/screens/track_metadata_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/upload_entry_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/upload_progress_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/your_uploads_screen.dart';
import '../features/auth/presentation/screens/account_screen.dart';
import '../features/auth/presentation/screens/password_reset_success_screen.dart';
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
import '../features/auth/presentation/screens/google_account_linking_screen.dart';
import '../features/messaging_track_sharing/presentation/screens/messaging_activity_screen.dart';
import '../features/messaging_track_sharing/domain/entities/message_attachment.dart';
import '../features/messaging_track_sharing/presentation/screens/chat_screen.dart';
import '../features/messaging_track_sharing/presentation/screens/inbox_settings_screen.dart';
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../features/playlists/presentation/screens/playlist_detail_screen.dart';
import '../features/playlists/presentation/screens/playlist_edit_screen.dart';
import '../features/playlists/presentation/screens/playlist_screen.dart';
import '../features/playlists/presentation/screens/albums_screen.dart';
import '../features/playlists/presentation/utils/shared_playlist_link_parser.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/playback_streaming_engine/presentation/screens/player_screen.dart';
import '../features/playback_streaming_engine/presentation/screens/queue_screen.dart';
import '../features/playback_streaming_engine/presentation/screens/listening_history_screen.dart';
import '../features/playback_streaming_engine/presentation/screens/shared_track_link_screen.dart';
import '../features/playback_streaming_engine/presentation/utils/shared_track_link_opener.dart';
import '../shared/ui/screens/settings_screen.dart';
import 'main_shell_screen.dart';
import 'route_guards.dart';

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
  static const String passwordResetSuccess = '/password-reset-success';
  static const String resetPassword = '/reset-password';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String profile = '/profile';
  static const String deleteAccount = '/delete-account';
  static const String googleAccountLinking = '/google-account-linking';
  static const String home = '/home';

  /// Internal entry path to open a track when all we have is (trackId,
  /// optional privateToken) — used by the private-link flow.
  /// Arguments: { 'trackId': String, 'privateToken': String? }
  static const String privateTrack = '/private-track';
}

Route<dynamic> generateRoute(RouteSettings settings) =>
    AppRouter.onGenerateRoute(settings);

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = _readArgs(settings.arguments);
    final sharedPlaylistLink = settings.name == null
        ? null
        : parsePlaylistShareLink(settings.name!);
    final sharedTrackLink = settings.name == null
        ? null
        : parseTrackShareLink(settings.name!);
    if (sharedPlaylistLink != null) {
      return _slideUp(
        AuthProtectedScreen(
          child: PlaylistDetailScreen(
            playlistId: sharedPlaylistLink.playlistId,
            secretToken: sharedPlaylistLink.secretToken,
          ),
        ),
        settings,
      );
    }
    if (sharedTrackLink != null) {
      return _slideUp(
        AuthProtectedScreen(
          child: SharedTrackLinkScreen(
            trackId: sharedTrackLink.trackId,
            privateToken: sharedTrackLink.privateToken,
          ),
        ),
        settings,
      );
    }

    switch (settings.name) {
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

      case AppRoutes.passwordResetSuccess:
        return _fade(
          PasswordResetSuccessScreen(email: args['email'] as String? ?? ''),
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

      case AppRoutes.settings:
        return _slide(
          const AuthProtectedScreen(child: SettingsScreen()),
          settings,
        );

      case AppRoutes.account:
        return _fade(
          const AuthProtectedScreen(child: AccountScreen()),
          settings,
        );

      case AppRoutes.profile:
        return _fade(
          const AuthProtectedScreen(child: ProfileScreen()),
          settings,
        );

      case AppRoutes.deleteAccount:
        return _fade(
          const AuthProtectedScreen(child: DeleteAccountScreen()),
          settings,
        );

      case AppRoutes.googleAccountLinking:
        return _fade(
          GoogleAccountLinkingScreen(
            linkingToken: args['linkingToken'] as String? ?? '',
            email: args['email'] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.home:
      case Routes.shell:
        return _fade(
          const AuthProtectedScreen(child: MainShellScreen()),
          settings,
        );

      case Routes.uploadEntry:
        return _slide(
          const AuthProtectedScreen(child: UploadEntryScreen()),
          settings,
        );

      case Routes.trackMetadata:
        return _slide(
          AuthProtectedScreen(
            child: TrackMetadataScreen(
              trackId: args['trackId'] as String? ?? '',
              fileName: args['fileName'] as String? ?? '',
            ),
          ),
          settings,
        );

      case Routes.uploadProgress:
        return _slide(
          const AuthProtectedScreen(child: UploadProgressScreen()),
          settings,
        );

      case Routes.editTrack:
        final item = settings.arguments as UploadItem;
        return _slide(
          AuthProtectedScreen(child: EditTrackScreen(item: item)),
          settings,
        );

      case Routes.trackDetail:
        final item = settings.arguments as UploadItem;
        return _slide(
          AuthProtectedScreen(child: TrackDetailScreen(item: item)),
          settings,
        );

      case AppRoutes.privateTrack:
        final trackId = (args['trackId'] as String?)?.trim() ?? '';
        final privateToken = args['privateToken'] as String?;
        final stub = TrackLinkHelper.buildStubUploadItem(
          trackId,
          privateToken: privateToken,
        );
        return _slide(
          AuthProtectedScreen(child: TrackDetailScreen(item: stub)),
          settings,
        );

      case Routes.yourUploads:
        return _slide(
          const AuthProtectedScreen(child: YourUploadsScreen()),
          settings,
        );

      case Routes.player:
        return _slideUp(
          const AuthProtectedScreen(child: PlayerScreen()),
          settings,
        );

      case Routes.queue:
        return _slide(
          const AuthProtectedScreen(child: QueueScreen()),
          settings,
        );

      case Routes.listeningHistory:
        return _slide(
          const AuthProtectedScreen(child: ListeningHistoryScreen()),
          settings,
        );

      case Routes.messagingActivity:
        return _slide(
          const AuthProtectedScreen(child: MessagingActivityScreen()),
          settings,
        );

      case Routes.inboxSettings:
        return _slide(
          const AuthProtectedScreen(child: InboxSettingsScreen()),
          settings,
        );

      case Routes.chat:
        return _slide(
          AuthProtectedScreen(
            child: ChatScreen(
              conversationId: args['conversationId'] as String? ?? '',
              otherUserId: args['otherUserId'] as String?,
              otherUserName: args['otherUserName'] as String? ?? '',
              otherUserAvatar: args['otherUserAvatar'] as String?,
              pendingAttachment:
                  args['pendingAttachment'] as MessageAttachment?,
            ),
          ),
          settings,
        );

      case Routes.notificationPreferences:
        return _slide(
          const AuthProtectedScreen(child: NotificationPreferencesScreen()),
          settings,
        );

      case Routes.playlists:
        return _slide(
          const AuthProtectedScreen(child: PlaylistsScreen()),
          settings,
        );
      case Routes.albums:
        return _slide(
          const AuthProtectedScreen(child: AlbumsScreen()),
          settings,
        );

      case Routes.playlistDetail:
        final id = args['playlistId'] as String? ?? '';
        final isMine = args['isMine'] as bool? ?? true;
        return _slide(
          AuthProtectedScreen(
            child: PlaylistDetailScreen(playlistId: id, isMine: isMine),
          ),
          settings,
        );

      case Routes.playlistEdit:
        final collectionId = args['collectionId'] as String? ?? '';
        return _slide(
          AuthProtectedScreen(
            child: PlaylistEditScreen(collectionId: collectionId),
          ),
          settings,
        );

      default:
        return _fade(const AuthGate(), settings);
    }
  }

  static Map<String, dynamic> _readArgs(Object? rawArgs) {
    if (rawArgs is Map) {
      return rawArgs.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static PageRouteBuilder<T> _fade<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<T> _slide<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.ease)).animate(animation),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<T> _slideUp<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
