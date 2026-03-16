import 'package:flutter/material.dart';

import '../features/audio_upload_and_management/domain/entities/upload_item.dart';
import '../features/audio_upload_and_management/presentation/screens/edit_track_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/track_metadata_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/upload_entry_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/upload_progress_screen.dart';
import '../features/audio_upload_and_management/presentation/screens/your_uploads_screen.dart';
import 'main_shell_screen.dart';
import '../core/routing/routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.shell:
        return _fade(const MainShellScreen());

      case Routes.uploadEntry:
        return _slide(const UploadEntryScreen());

      case Routes.trackMetadata:
        final args = settings.arguments as Map<String, String>;
        return _slide(
          TrackMetadataScreen(
            trackId: args['trackId']!,
            fileName: args['fileName']!,
          ),
        );

      case Routes.uploadProgress:
        return _slide(const UploadProgressScreen());

      case Routes.editTrack:
        final item = settings.arguments as UploadItem;
        return _slide(EditTrackScreen(item: item));

      case Routes.trackDetail:
        final item = settings.arguments as UploadItem;
        return _slide(TrackDetailScreen(item: item));

      case Routes.yourUploads:
        return _slide(const YourUploadsScreen());

      default:
        return _fade(const MainShellScreen());
    }
  }

  static MaterialPageRoute<T> _fade<T>(Widget page) =>
      MaterialPageRoute<T>(builder: (_) => page);

  static PageRouteBuilder<T> _slide<T>(Widget page) => PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.ease)).animate(anim),
      child: child,
    ),
  );
}
