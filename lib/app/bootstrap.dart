import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'route_guards.dart';
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
  // Must be called before any Flutter framework APIs are used.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — the app is not designed for landscape.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make the status bar transparent and match the system nav bar
  // to the app's dark background so there is no colour mismatch.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ProviderScope is the Riverpod equivalent of a DI container.
    // It must wrap the entire widget tree so every ConsumerWidget
    // and ref.read() / ref.watch() call can reach the providers.
    const ProviderScope(child: TunifyApp()),
  );
}

/// The root widget of the application.
///
/// Configures [MaterialApp] with:
/// - The global dark [ThemeData] derived from [AppColors].
/// - [generateRoute] as the named route factory.
/// - [AuthGate] as the home widget — it performs the initial
///   auth check and redirects to home or landing before the
///   user sees anything.
class TunifyApp extends StatelessWidget {
  const TunifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundCloud',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      onGenerateRoute: generateRoute,
      // AuthGate performs the token check on cold start.
      // It replaces itself immediately — the user never sees it directly.
      home: const AuthGate(),
    );
  }

  /// Builds the app-wide [ThemeData].
  ///
  /// All values derive from [AppColors] so changing the palette
  /// in one place updates the entire app. Individual widget styles
  /// (buttons, inputs) are defined in their own widget files and
  /// do NOT rely on the theme — they use [AppColors] directly.
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
      // White cursor matches the dark theme across all text fields.
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.onBackground,
      ),
    );
  }
}
