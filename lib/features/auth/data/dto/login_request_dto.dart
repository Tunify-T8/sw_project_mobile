/// Data Transfer Object used to send login credentials to the authentication API.
///
/// This DTO belongs to the data layer and is responsible for converting
/// login credentials into a JSON format that can be sent to the backend
/// authentication endpoint.
///
/// Used by the remote data source when performing a login request.
class LoginRequestDTO {
  /// Email address of the user attempting to log in.
  final String email;

  /// Password associated with the user's account.
  final String password;

  /// Constructor to create an instance of [LoginRequestDTO].
  LoginRequestDTO({required this.email, required this.password});

  /// Converts the login request object into a JSON map
  /// to be sent in the API request body.
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
