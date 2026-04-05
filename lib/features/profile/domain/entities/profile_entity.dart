class ProfileEntity {
  final String id;
  final String userName;
  final String? displayName;
  final String? email;  // Nullable for public profiles
  final String role;
  final String bio;
  final String city;
  final String country;
  final String? profileImagePath;
  final String? coverImagePath;
  final String? instagram;  // Nullable for public profiles
  final String? twitter;  // Nullable for public profiles
  final String? youtube;  // Nullable for public profiles
  final String? spotify;  // Nullable for public profiles
  final String? tiktok;  // Nullable for public profiles
  final String? soundcloud;  // Nullable for public profiles
  final int? followersCount;  // Nullable for private profiles
  final int? followingCount;  // Nullable for private profiles
  final int? tracksCount;  // Nullable for private profiles
  final int? likesReceived;  // Nullable for private profiles
  final String? visibility;  // Nullable for public profiles
  final String userType;
  final bool? isActive;  // Nullable for public profiles
  final bool? isCertified;  // Nullable for public profiles

  // Computed property to determine if this is a public profile
  bool get isPublic => tracksCount != null && followersCount != null && followingCount != null && likesReceived != null;

  const ProfileEntity({
    required this.id,
    required this.userName,
    this.displayName,
    this.email,
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
    this.followersCount,
    this.followingCount,
    this.tracksCount,
    this.likesReceived,
    this.visibility,
    required this.userType,
    this.isActive,
    this.isCertified,
  });
}
