class ProfileEntity {
  final String id;
  final String userName;
  final String? displayName;
  final String email;
  final String role;
  final String bio;
  final String city;
  final String country;
  final String? profileImagePath;
  final String? coverImagePath;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? spotify;
  final String? tiktok;
  final String? soundcloud;
  final int followersCount;
  final int followingCount;
  final int tracksCount;
  final int likesReceived;
  final String visibility;
  final String userType;
  final bool isActive;
  final bool isCertified;

  const ProfileEntity({
    required this.id,
    required this.userName,
    this.displayName,
    required this.email,
    required this.role,
    required this.bio,
    required this.city,
    required this.country,
    this.profileImagePath,
    this.coverImagePath,
    this.instagram,
    this.twitter,
    this.youtube,
    this.spotify,
    this.tiktok,
    this.soundcloud,
    this.followersCount = 0,
    this.followingCount = 0,
    this.tracksCount = 0,
    this.likesReceived = 0,
    this.visibility = 'PUBLIC',
    this.userType = 'ARTIST',
    this.isActive = true,
    this.isCertified = false,
  });
}
