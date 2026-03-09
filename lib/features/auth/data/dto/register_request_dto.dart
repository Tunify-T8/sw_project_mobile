/// Data Transfer Object used to send registration information to the API.
///
/// This DTO belongs to the data layer and represents the request body
/// required to create a new user account through the authentication service.
///
/// Used by the remote data source when performing a user registration request.
class RegisterRequestDTO {
  /// Email address used for the account.
  final String email;

  /// Password selected by the user for authentication.
  final String password;

  /// Username chosen by the user.
  final String username;

  /// Optional URL pointing to the user's avatar image.
  final String? avatarUrl;

  /// Constructor to create an instance of [RegisterRequestDTO].
  RegisterRequestDTO({
    required this.email,
    required this.password,
    required this.username,
    this.avatarUrl,
  });

  /// Converts the registration request object into JSON
  /// for transmission to the backend API.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      "avatarUrl": avatarUrl,
    };
  }
}
