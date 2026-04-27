import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/features/notifications/data/services/push_notification_service.dart';
import 'router.dart';

/// Initialises the Flutter framework and launches the app.
///
/// Called from [main.dart] as the single entry point:
/// ```dart
/// void main() => bootstrap();
/// ```
///
/// Responsibilities:
/// - Ensures Flutter bindings are ready before any platform calls.
/// - Locks the device to portrait orientation.
/// - Styles the status bar and navigation bar to match the dark theme.
/// - Wraps the app in [ProviderScope] (required by Riverpod for
///   all providers to work).
/// - Calls [runApp] with [TunifyApp].
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await PushNotificationService.instance.init();

  runApp(const ProviderScope(child: TunifyApp()));
}

/// The root widget of the application.
class TunifyApp extends StatelessWidget {
  const TunifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final platformRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    final initialRoute = platformRoute.startsWith('/tracks/')
        ? platformRoute
        : AppRoutes.authGate;

    return MaterialApp(
      title: 'Tunify',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      // Use initialRoute instead of home so that generateRoute handles
      // every route from the very first frame, including '/'.
      // home + onGenerateRoute conflict because home bypasses the route
      // generator entirely for the first screen, making pushReplacementNamed
      // from initState unreliable before the navigator is ready.
      initialRoute: initialRoute,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.onBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onBackground),
        titleTextStyle: TextStyle(
          color: AppColors.onBackground,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(
          color: AppColors.onBackground,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.onBackground,
      ),
    );
  }
}
