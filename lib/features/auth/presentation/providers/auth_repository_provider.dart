/// Repository provider for the auth feature.
///
/// ── RESPONSIBILITY ───────────────────────────────────────────────────────────
/// Wires the concrete [AuthRepository] implementation — either the real
/// backend implementation or the mock — based on [MockAuthConfig.useMock].
///
/// ── WHY SEPARATE ─────────────────────────────────────────────────────────────
/// The repository provider is the seam between the data layer and the domain
/// layer. Keeping it in its own file means:
///   - Tests can override just [authRepositoryProvider] without importing
///     all use-case or controller code.
///   - Switching from mock to real only requires a change here (plus
///     toggling [MockAuthConfig.useMock]).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_config.dart';
import 'package:software_project/features/auth/data/mock/mock_auth_repository.dart';
import 'package:software_project/features/auth/data/repository/auth_repository_impl.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'auth_infrastructure_providers.dart';

/// Provides the active [AuthRepository].
///
/// When [MockAuthConfig.useMock] is `true`, returns [MockAuthRepository] backed
/// by the in-memory [MockAuthService]. When `false`, returns
/// [AuthRepositoryImpl] which calls the real Tunify backend.
///
/// Override in tests:
/// ```dart
/// authRepositoryProvider.overrideWithValue(FakeAuthRepository())
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);

  if (MockAuthConfig.useMock) {
    return MockAuthRepository(tokenStorage: tokenStorage);
  }

  return AuthRepositoryImpl(ref.read(authApiProvider), tokenStorage);
});
