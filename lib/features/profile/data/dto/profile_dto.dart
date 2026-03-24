class ProfileDto {
  //// Server-controlled which means it shouldn't be edited bu user(backend logic only, never triggered by user action)
  final String id;
  final String email;
  final String role;
  final int tracksCount;
  final int likesReceived;
  final bool isActive;
  final int followersCount;
  final int followingCount;
  // User-editable
  final String userName;
  final String? displayName;
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
  final String visibility;
  final String userType;
  final bool isCertified;

  ProfileDto({
    // Server-controlled->edit_screen doesn't need them
    // real values always carried from provider in profile_action_buttons
    this.id = '',
    this.email = '',
    this.role = 'USER',
    this.tracksCount = 0,
    this.likesReceived = 0,
    this.isActive = true,
    this.isCertified = false,
    // Read-only — defaults so edit_screen doesn't need them
    this.followersCount = 0,
    this.followingCount = 0,
    // User-editable —> always required
    required this.userName,
    this.displayName,
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
    this.visibility = 'PUBLIC',
    required this.userType,
  });
}
