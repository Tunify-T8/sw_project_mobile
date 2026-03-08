/// Represents an authenticated user within the application.
///
/// This entity belongs to the domain layer and contains core user information
/// required by the authentication module.
///
/// Used throughout the application
/// to represent the currently logged-in user.
class AuthUserEntity {
  /// Unique Id for the user.
  final String id;

  /// Email address associated with the user's account.
  final String email;

  /// Username chosen by the user.
  final String username;

  /// Constructor to create an instance of [AuthUserEntity].
  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.username,
  });
}
