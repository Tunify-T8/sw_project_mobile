class ProfileDto {
  final String username;
  final String bio;
  final String location;
  final String? avatarPath;
  final String? coverPath;
  final String? instagram;
  final String? twitter;
  final String? website;
  // TODO: add genres later

  ProfileDto({
    required this.username,
    required this.bio,
    required this.location,
    this.avatarPath,
    this.coverPath,
    this.instagram,
    this.twitter,
    this.website,
  });
}