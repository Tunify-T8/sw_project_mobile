/// Represents a domain-level failure that can occur during any operation.
///
/// This lives in the domain layer so use cases and the presentation
/// layer can handle errors without depending on Dio or any other
/// data-layer detail.
///
/// Each subclass represents a distinct category of failure,
/// making it easy to display the correct message in the UI.
abstract class Failure {
  /// Human-readable message describing what went wrong.
  final String message;

  const Failure(this.message);
}

/// Failure caused by an unauthenticated or invalid credential response (401).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
    : super('Invalid credentials. Please check your email and password.');
}

/// Failure caused by a conflict, e.g. email already registered (409).
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

/// Failure caused by a validation error returned by the server (400).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure caused by a server-side error (5xx).
class ServerFailure extends Failure {
  const ServerFailure() : super('A server error occurred. Please try again.');
}

/// Failure caused by no internet connection or a timeout.
class NetworkFailure extends Failure {
  const NetworkFailure()
    : super('No internet connection. Please check your network.');
}

/// Failure caused by any unexpected or unclassified error.
class UnknownFailure extends Failure {
  const UnknownFailure() : super('An unexpected error occurred.');
}
