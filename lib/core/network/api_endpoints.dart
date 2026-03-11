/// Centralized API endpoint definitions.
///
/// All backend route paths are declared here to avoid
/// hardcoding strings across the application and to make
/// future endpoint changes easy to manage.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String logout = "/auth/logout";
  static const String refreshToken = "/auth/refresh";
  static const String oauthLogin = "/auth/oauth";
}
