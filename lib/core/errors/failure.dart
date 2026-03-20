/// Base class for all domain-level failures.
///
/// Lives in the domain layer so use cases and the presentation layer
/// can handle errors without depending on Dio or any data-layer detail.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// HTTP 400 — validation error.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// HTTP 401 — wrong credentials.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
    : super('Invalid credentials. Please check your email and password.');
}

/// Login succeeded but the account is not yet email-verified.
///
/// The presentation layer should show the verify-email flow.
class UnverifiedUserFailure extends Failure {
  const UnverifiedUserFailure()
    : super('Please verify your email before logging in.');
}

/// HTTP 403 — account banned or suspended.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}

/// HTTP 404 — resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// HTTP 409 — duplicate email or username.
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

/// HTTP 5xx — server-side error.
class ServerFailure extends Failure {
  const ServerFailure() : super('A server error occurred. Please try again.');
}

/// No internet connection or request timeout.
class NetworkFailure extends Failure {
  const NetworkFailure()
    : super('No internet connection. Please check your network.');
}

/// Any unexpected or unclassified error.
class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred.');
}
