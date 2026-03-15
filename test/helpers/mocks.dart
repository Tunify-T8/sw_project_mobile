import 'package:mockito/annotations.dart';
import 'package:software_project/core/storage/token_storage.dart';
import 'package:software_project/features/auth/data/api/auth_api.dart';
import 'package:software_project/features/auth/data/services/google_sign_in_service.dart';
import 'package:software_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:software_project/features/auth/domain/usecases/check_email_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_all_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:software_project/features/auth/domain/usecases/verify_email_usecase.dart';

/// Central mock generation file.
///
/// ALL mocks for the auth module are declared here in a single
/// @GenerateMocks annotation. Build_runner reads this file and
/// generates test/helpers/mocks.mocks.dart containing every Mock class.
///
/// Every test file imports:
///   import '../helpers/mocks.dart';          // for the type names
///   import '../helpers/mocks.mocks.dart';    // for the generated MockXxx classes
///
/// To add a new mock: add the class to the list below, then run:
///   dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  // ── Repository contract ───────────────────────────────────────────────────
  AuthRepository,

  // ── Data layer ────────────────────────────────────────────────────────────
  AuthApi,
  TokenStorage,

  // ── Use cases ─────────────────────────────────────────────────────────────
  CheckEmailUseCase,
  RegisterUseCase,
  VerifyEmailUseCase,
  ResendVerificationUseCase,
  LoginUseCase,
  LogoutUseCase,
  LogoutAllUseCase,
  ForgotPasswordUseCase,
  ResetPasswordUseCase,
  DeleteAccountUseCase,

  // ── Services ──────────────────────────────────────────────────────────────
  GoogleSignInService,
])
void main() {}
