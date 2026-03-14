class ProfileDto {
  final String userName;
  final String city;
  final String country;
  final String bio;
  final String? profileImagePath;
  final String? coverImagePath;
  // I will add genres later
  // I will add playlists later

  ProfileDto({
    required this.userName,
    required this.city,
    required this.country,
    required this.bio,
    this.profileImagePath,
    this.coverImagePath,
  });
}