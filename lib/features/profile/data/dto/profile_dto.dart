class ProfileDto {
  final String userName;
  final String city;
  final String country;
  final String bio;
  final String? profileImagePath;
  final String? coverImagePath;
  final String? instagram;
  final String? twitter;
  final String? website;
  // TODO: add genres later
  // TODO: add playlists later

  ProfileDto({
    required this.userName,
    required this.city,
    required this.country,
    required this.bio,
    this.profileImagePath,
    this.coverImagePath,
    this.instagram,
    this.twitter,
    this.website,
  });
}