import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/design_system/colors.dart';
import 'package:software_project/core/routing/routes.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

import 'router.dart';

class RouteGuard {
  final TokenStorage _tokenStorage;

  const RouteGuard(this._tokenStorage);

  static const List<String> _protectedRoutes = [
    AppRoutes.home,
    AppRoutes.settings,
    AppRoutes.account,
    AppRoutes.profile,
    AppRoutes.deleteAccount,
    Routes.shell,
    Routes.uploadEntry,
    Routes.trackMetadata,
    Routes.uploadProgress,
    Routes.editTrack,
    Routes.trackDetail,
    Routes.yourUploads,
  ];

  static const List<String> _authOnlyRoutes = [
    AppRoutes.landing,
    AppRoutes.signInOrCreate,
    AppRoutes.emailEntry,
    AppRoutes.password,
    AppRoutes.registerDetail,
    AppRoutes.tellUsMore,
    AppRoutes.forgotPassword,
    AppRoutes.passwordResetSuccess,
    AppRoutes.resetPassword,
  ];

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

class AuthProtectedScreen extends ConsumerStatefulWidget {
  final Widget child;

  const AuthProtectedScreen({super.key, required this.child});

  @override
  ConsumerState<AuthProtectedScreen> createState() =>
      _AuthProtectedScreenState();
}

class _AuthProtectedScreenState extends ConsumerState<AuthProtectedScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final hasToken = await tokenStorage.hasAccessToken();

    if (!mounted) return;

    if (!hasToken) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.landing,
        (route) => false,
      );
      return;
    }

    final user = await ref
        .read(authControllerProvider.notifier)
        .restoreSession();

    if (!mounted) return;

    if (user == null) {
      await tokenStorage.clearSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.landing,
        (route) => false,
      );
      return;
    }

    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return widget.child;
  }
}

class AuthGate extends ConsumerStatefulWidget {
  final TokenStorage tokenStorage;

  const AuthGate({super.key, this.tokenStorage = const TokenStorage()});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final hasToken = await widget.tokenStorage.hasAccessToken();
    String destination = AppRoutes.landing;

    if (hasToken) {
      final user = await ref
          .read(authControllerProvider.notifier)
          .restoreSession();
      if (user != null) {
        destination = AppRoutes.home;
      } else {
        await widget.tokenStorage.clearSession();
      }
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.splash,
      arguments: {'destination': destination},
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.shrink(),
    );
  }
}
