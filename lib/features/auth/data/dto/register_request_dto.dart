/// Request body for POST /auth/register.
class RegisterRequestDto {
  final String email;
  final String username;
  final String password;
  final String gender;
  final String dateOfBirth; // ISO string e.g. "1995-06-15"
  final String? avatarUrl;

  const RegisterRequestDto({
    required this.email,
    required this.username,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'password': password,
    'gender': gender,
    'date_of_birth': dateOfBirth,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}
