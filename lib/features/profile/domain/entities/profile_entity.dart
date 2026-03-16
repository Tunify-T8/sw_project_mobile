class ProfileEntity {
  final String userName;
  final String city;
  final String country;
  final String bio;
  final String? profileImagePath;
  final String? coverImagePath;
  final String? instagram;
  final String? twitter;
  final String? website;
  final int followersCount;
  final int followingCount;
  final String visibility;
  final String userType;

  ProfileEntity({
    required this.userName,
    required this.city,
    required this.country,
    required this.bio,
    this.profileImagePath,
    this.coverImagePath,
    this.instagram,
    this.twitter,
    this.website,
    this.followersCount = 0,
    this.followingCount = 0,
    this.visibility = 'PUBLIC',
    this.userType = 'ARTIST',
  });
}
///this here is the object itself