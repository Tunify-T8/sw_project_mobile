class ProfileDto {
  //// Server-controlled which means it shouldn't be edited bu user(backend logic only, never triggered by user action)
  final String id;
  final String? email;  // Nullable for public profiles
  final String role;
  final int? tracksCount;  // Nullable for private profiles
  final int? likesReceived;  // Nullable for private profiles
  final bool? isActive;
  final int? followersCount;  // Nullable for private profiles
  final int? followingCount;  // Nullable for private profiles
  // User-editable
  final String userName;
  final String? displayName;
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
  final String? visibility;  // Nullable for public profiles
  final String userType;
  final bool? isCertified;

  // Computed property to determine if this is a public profile
  bool get isPublic => tracksCount != null && followersCount != null && followingCount != null && likesReceived != null;

  ProfileDto({
    // Server-controlled->edit_screen doesn't need them
    // real values always carried from provider in profile_action_buttons
    this.id = '',
    this.email,
    this.role = 'USER',
    this.tracksCount,
    this.likesReceived,
    this.isActive,
    this.isCertified,
    // Read-only — defaults so edit_screen doesn't need them
    this.followersCount,
    this.followingCount,
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
    this.visibility,
    this.userType = 'ARTIST',
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'USER',
      tracksCount: json['tracksCount'] as int?,
      likesReceived: json['likesReceived'] as int?,
      isActive: json['isActive'] as bool?,
      isCertified: json['isVerified'] as bool?, // Note: API uses 'isVerified', we map to 'isCertified'
      followersCount: json['followersCount'] as int?,
      followingCount: json['followingCount'] as int?,
      userName: json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String? ?? '',
      city: json['location']?.split(',')[0]?.trim() ?? '', // Parse location "NYC" -> city: "NYC"
      country: json['location']?.split(',')[1]?.trim() ?? '', // Parse location "NYC" -> country: "" (if no comma)
      profileImagePath: json['avatarUrl'] as String?,
      coverImagePath: json['coverUrl'] as String?,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      youtube: json['youtube'] as String?,
      spotify: json['spotify'] as String?,
      tiktok: json['tiktok'] as String?,
      soundcloud: json['soundcloud'] as String?,
      visibility: json['visibility'] as String?,
      userType: json['userType'] as String? ?? 'ARTIST',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'tracksCount': tracksCount,
      'likesReceived': likesReceived,
      'isActive': isActive,
      'isCertified': isCertified,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'userName': userName,
      'displayName': displayName,
      'bio': bio,
      'city': city,
      'country': country,
      'profileImagePath': profileImagePath,
      'coverImagePath': coverImagePath,
      'instagram': instagram,
      'twitter': twitter,
      'youtube': youtube,
      'spotify': spotify,
      'tiktok': tiktok,
      'soundcloud': soundcloud,
      'visibility': visibility,
      'userType': userType,
    };
  }
}
