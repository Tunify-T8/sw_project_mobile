import 'user_dto.dart';

/// Data Transfer Object representing the authentication response
/// returned by the backend API.
///
/// This DTO belongs to the data layer and is responsible for parsing
/// the response received after successful authentication operations
/// such as login or user registration.
///
/// The response typically contains the authenticated user information
/// along with the access and refresh tokens required for authorized requests.
class AuthResponseDTO {
  /// The authenticated user returned by the API.
  final UserDTO user;

  /// JWT access token used to authenticate API requests.
  final String accessToken;

  /// Refresh token used to obtain a new access token when the current one expires.
  final String refreshToken;

  /// Duration in seconds before the access token expires.
  final int accessTokenExpiresIn;

  /// Constructor to create an instance of [AuthResponseDTO].
  AuthResponseDTO({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresIn,
  });

  /// Creates an [AuthResponseDTO] instance from a JSON response returned by the API.
  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) {
    return AuthResponseDTO(
      user: UserDTO.fromJson(json["user"]),
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      accessTokenExpiresIn: json["accessTokenExpiresIn"],
    );
  }
}
