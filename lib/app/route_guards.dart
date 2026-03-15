import 'package:flutter/material.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'router.dart';

/// Evaluates whether a user is allowed to navigate to a given route.
///
/// There are two protection rules:
///
/// 1. Protected routes (require a stored token):
///    If the user has no token and tries to reach [AppRoutes.home]
///    or [AppRoutes.deleteAccount], they are redirected to [AppRoutes.landing].
///
/// 2. Auth-only routes (require no stored token):
///    If the user already has a token and tries to reach any sign-in or
///    register screen, they are redirected to [AppRoutes.home].
///
/// All other routes are allowed through unchanged.
///
/// Usage inside [MaterialApp.onGenerateRoute]:
/// ```dart
/// final allowed = await RouteGuard(tokenStorage).evaluate(settings.name);
/// // then build the screen for `allowed`
/// ```
class RouteGuard {
  final TokenStorage _tokenStorage;

  const RouteGuard(this._tokenStorage);

  /// Routes that require an authenticated session (stored token).
  static const List<String> _protectedRoutes = [
    AppRoutes.home,
    AppRoutes.deleteAccount,
  ];

  /// Routes that are only reachable when the user is unauthenticated.
  static const List<String> _authOnlyRoutes = [
    AppRoutes.landing,
    AppRoutes.signInOrCreate,
    AppRoutes.emailEntry,
    AppRoutes.password,
    AppRoutes.registerDetail,
    AppRoutes.tellUsMore,
    AppRoutes.forgotPassword,
    AppRoutes.checkYourEmail,
    AppRoutes.resetPassword,
  ];

  /// Returns the route to actually navigate to.
  ///
  /// If navigation is allowed, [routeName] is returned unchanged.
  /// If blocked by a protection rule, the redirect route is returned.
  Future<String> evaluate(String? routeName) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    final route = routeName ?? AppRoutes.splash;

    if (!hasToken && _protectedRoutes.contains(route)) {
      return AppRoutes.landing;
    }
    if (hasToken && _authOnlyRoutes.contains(route)) {
      return AppRoutes.home;
    }
    return route;
  }
}

/// The first widget shown on cold start.
///
/// Checks whether a valid access token is stored and immediately
/// replaces itself with either [AppRoutes.home] or [AppRoutes.landing].
/// It never stays visible — it shows only for the milliseconds
/// it takes to read from secure storage.
///
/// This widget is set as [MaterialApp.home] in [bootstrap.dart].
/// The actual first visible screen for the user is the splash screen
/// ([AppRoutes.splash] is the initial route once auth is determined
/// — but the splash screen handles its own auth check, so [AuthGate]
/// bypasses splash and goes directly to home or landing).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    const tokenStorage = TokenStorage();
    final hasToken = await tokenStorage.hasAccessToken();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      hasToken ? AppRoutes.home : AppRoutes.landing,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shown only for the brief moment the token check runs.
    // Uses AppColors so the background matches the rest of the app.
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
