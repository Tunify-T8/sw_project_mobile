import 'package:flutter/material.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/storage/token_storage.dart';

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

/// Entry point for auth-based navigation.
///
/// On cold start the app always begins at [AppRoutes.authGate], which
/// builds this widget.
///
/// AuthGate checks whether an access token exists and then navigates to
/// [AppRoutes.splash], passing the intended post-splash destination.
///
/// This keeps token-check logic centralized and makes the widget easy to
/// test by accepting a [TokenStorage] instance via constructor.
class AuthGate extends StatefulWidget {
  /// Allows tests to inject a fake [TokenStorage].
  /// Production code relies on the default [TokenStorage()] instance.
  final TokenStorage tokenStorage;

  const AuthGate({super.key, this.tokenStorage = const TokenStorage()});

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
    final hasToken = await widget.tokenStorage.hasAccessToken();
    if (!mounted) return;

    // Always go through splash so the animation plays on every cold start.
    // SplashScreen receives the post-auth destination via route arguments
    // and navigates there after the animation completes.
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.splash,
      arguments: {'destination': hasToken ? AppRoutes.home : AppRoutes.landing},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Blank screen shown only for the brief moment the token check runs.
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.shrink(),
    );
  }
}
