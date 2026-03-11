import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/core/network/dio_client.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/repository/auth_repository_impl.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:software_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/oauth_login_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/register_usecase.dart';

// ─── Infrastructure Providers ────────────────────────────────────────────────

/// Provides a singleton [TokenStorage] instance.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});

/// Provides a configured [Dio]-backed [AuthApi] instance.
final authApiProvider = Provider<AuthApi>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final dio = DioClient.create(tokenStorage);
  return AuthApi(dio);
});

// ─── Repository Provider ─────────────────────────────────────────────────────

/// Provides the [AuthRepository] implementation.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authApiProvider),
    ref.read(tokenStorageProvider),
  );
});

// ─── Use Case Providers ───────────────────────────────────────────────────────

/// Provides the [LoginUseCase].
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

/// Provides the [RegisterUseCase].
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

/// Provides the [LogoutUseCase].
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

/// Provides the [OAuthLoginUseCase].
final oauthLoginUseCaseProvider = Provider<OAuthLoginUseCase>((ref) {
  return OAuthLoginUseCase(ref.read(authRepositoryProvider));
});

// ─── Controller Provider ──────────────────────────────────────────────────────

/// Provides and manages the [AuthController] state.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthUserEntity?>>((ref) {
      return AuthController(
        loginUseCase: ref.read(loginUseCaseProvider),
        registerUseCase: ref.read(registerUseCaseProvider),
        logoutUseCase: ref.read(logoutUseCaseProvider),
        oauthLoginUseCase: ref.read(oauthLoginUseCaseProvider),
      );
    });

// ─── Controller ───────────────────────────────────────────────────────────────

/// Manages authentication state for the presentation layer.
///
/// Exposes async state as [AsyncValue<AuthUserEntity?>]:
/// - `null`    → user is unauthenticated
/// - `data`    → authenticated user entity
/// - `loading` → an operation is in progress
/// - `error`   → the last operation failed with a [Failure]
class AuthController extends StateNotifier<AsyncValue<AuthUserEntity?>> {
  /// Use case responsible for logging in with email and password.
  final LoginUseCase loginUseCase;

  /// Use case responsible for registering a new user account.
  final RegisterUseCase registerUseCase;

  /// Use case responsible for logging the current user out.
  final LogoutUseCase logoutUseCase;

  /// Use case responsible for authenticating via an OAuth provider.
  final OAuthLoginUseCase oauthLoginUseCase;

  /// Creates an [AuthController] with all required use cases.
  ///
  /// Initial state is [AsyncValue.data(null)], representing
  /// an unauthenticated session.
  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.oauthLoginUseCase,
  }) : super(const AsyncValue.data(null));

  /// Authenticates a user with [email] and [password].
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await loginUseCase(email, password);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Registers a new user with [email], [password], and [username].
  Future<void> register(String email, String password, String username) async {
    state = const AsyncValue.loading();
    try {
      final user = await registerUseCase(email, password, username);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Authenticates via OAuth using [provider] and identity [token].
  Future<void> oauthLogin(String provider, String token) async {
    state = const AsyncValue.loading();
    try {
      final user = await oauthLoginUseCase(provider, token);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  /// Logs the current user out and resets state.
  Future<void> logout() async {
    await logoutUseCase();
    state = const AsyncValue.data(null);
  }
}
