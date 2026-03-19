class ProfileDto {
  //// Server-controlled which means it shouldn't be edited bu user(backend logic only, never triggered by user action)
  final String id;
  final String email;
  final String role;
  final int tracksCount;
  final int likesReceived;
  final bool isActive;
  final bool isVerified;
  ////Read only (comes form backend too; changes happen but not through user editing a form)
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
  final String? website;
  final String visibility;
  final String userType;

  ProfileDto({
    // Server-controlled->edit_screen doesn't need them
    // real values always carried from provider in profile_action_buttons
    this.id = '',
    this.email = '',
    this.role = 'USER',
    this.tracksCount = 0,
    this.likesReceived = 0,
    this.isActive = true,
    this.isVerified = false,
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
    this.website,
    this.visibility = 'PUBLIC',
    required this.userType,
  });
}