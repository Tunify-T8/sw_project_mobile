/// Infrastructure providers for the auth feature.
///
/// ── RESPONSIBILITY ───────────────────────────────────────────────────────────
/// Owns the three low-level singleton providers that wire concrete
/// implementations to the network, storage, and external SDK layers:
///   - [tokenStorageProvider]       — secure token/session persistence
///   - [authApiProvider]            — Dio-based HTTP client for /auth/* endpoints
///   - [googleSignInServiceProvider]— Google Sign-In SDK wrapper
///
/// ── WHY SEPARATE ─────────────────────────────────────────────────────────────
/// Previously all providers (infrastructure, repository, use-cases, controller)
/// lived in a single `auth_provider.dart` file — a SRP violation.
/// Infrastructure concerns are now isolated here so changes to Dio
/// configuration or token storage do not touch use-case wiring or controller
/// logic.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/services/google_sign_in_service.dart';

// ── Token storage ─────────────────────────────────────────────────────────────

/// Provides the [TokenStorage] singleton used to persist and retrieve
/// JWT access/refresh tokens and the cached [AuthUserEntity].
///
/// Shared across the auth feature — inject via `ref.read(tokenStorageProvider)`.
final tokenStorageProvider = Provider<TokenStorage>(
  (_) => const TokenStorage(),
);

// ── Auth API ──────────────────────────────────────────────────────────────────

/// Provides the [AuthApi] HTTP client pre-configured with the Dio interceptor
/// that automatically attaches the Bearer token on every request.
///
/// Depends on [tokenStorageProvider] to supply the interceptor with the
/// current access token.
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(DioClient.create(ref.read(tokenStorageProvider)));
});

// ── Google Sign-In ────────────────────────────────────────────────────────────

/// Provides the [GoogleSignInService] singleton that wraps the Google Sign-In
/// SDK and handles the authorization code flow.
///
/// [GoogleSignInService.signIn] returns a [GoogleSignInResult] containing the
/// `serverAuthCode` that must be forwarded to the backend within ~60 seconds.
final googleSignInServiceProvider = Provider<GoogleSignInService>(
  (_) => GoogleSignInService(),
);
