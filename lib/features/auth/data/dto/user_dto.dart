/// Data Transfer Object representing a user returned by the authentication API.
///
/// This DTO belongs to the data layer and is responsible for parsing
/// user information received from the backend authentication endpoints.
///
/// It contains only the user fields returned during authentication
/// such as login and registration responses.
class UserDTO {
  /// Unique identifier of the user.
  final String id;

  /// Username chosen by the user.
  final String username;

  /// Email address associated with the account.
  final String email;

  /// Optional URL pointing to the user's avatar image.
  final String? avatarUrl;

  /// Indicates whether the user has verified their email address.
  final bool isVerified;

  /// Constructor to create an instance of [UserDTO].
  UserDTO({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.isVerified,
  });

  /// Creates a [UserDTO] object from a JSON response returned by the API.
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      avatarUrl: json["avatarUrl"],
      isVerified: json["isVerified"],
    );
  }
}
