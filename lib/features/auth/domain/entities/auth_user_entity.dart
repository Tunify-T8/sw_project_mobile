/// Represents an authenticated user in the domain layer.
///
/// This is the single user model used by the presentation layer.
/// It is decoupled from any API response shape.
class AuthUserEntity {
  final String id;
  final String email;
  final String username;
  final String role;
  final bool isVerified;
  final String? avatarUrl;

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isVerified,
    this.avatarUrl,
  });
}
