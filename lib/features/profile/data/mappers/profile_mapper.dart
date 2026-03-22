import '../dto/profile_dto.dart';
// This file:
//Receives the raw JSON
// Converts it into a proper Dart object
// Splits "Cairo, Egypt" → city + country
// Merges profile + social links together
// Returns a clean ProfileDto

class ProfileMapper {
  static ProfileDto fromJson(Map<String, dynamic> json) {
    // MockAPI returns the object directly (no 'user' wrapper)
    // Real backend returns { "user": { ... } } so we handle both
    final user = json['user'] ?? json;

    // Split "Cairo, Egypt" into city: "Cairo", country: "Egypt"
    final locationRaw = user['location'] ?? '';
    final locationParts = locationRaw.split(',');
    final city = locationParts.isNotEmpty ? locationParts[0].trim() : '';
    final country = locationParts.length > 1 ? locationParts[1].trim() : '';

    return ProfileDto(
      id: user['id'] ?? '',          
      userName: user['username'] ?? '',
      displayName: user['displayName'], 
      email: user['email'] ?? '',     
      role: user['role'] ?? 'USER',   
      bio: user['bio'] ?? '',
      city: city,
      country: country,
      profileImagePath: user['avatarUrl'],
      coverImagePath: user['coverUrl'],
      followersCount: user['followersCount'] ?? 0,
      followingCount: user['followingCount'] ?? 0,
      tracksCount: user['tracksCount'] ?? 0,     
      likesReceived: user['likesReceived'] ?? 0,  
      userType: user['userType'] ?? 'ARTIST',
      visibility: user['visibility'] ?? 'PUBLIC',
      isActive: user['isActive'] ?? true,         
      isVerified: user['isVerified'] ?? false,    
      instagram: null,
      twitter: null,
    );
}

static ProfileDto mergeSocialLinks(
  ProfileDto profile,
  Map<String, dynamic> socialJson,
) {
  // Backend returns { "links": [ { "platform": "INSTAGRAM", "url": "..." } ] }
  final linksList = socialJson['links'] as List<dynamic>? ?? [];

  String? instagram;
  String? twitter;
  String? youtube;
  String? spotify;
  String? tiktok;
  String? soundcloud;

  for (final link in linksList) {
    final platform = (link['platform'] as String?)?.toUpperCase();
    final url = link['url'] as String?;
    switch (platform) {
      case 'INSTAGRAM':
        instagram = url;
        break;
      case 'TWITTER':
        twitter = url;
        break;
      case 'YOUTUBE':
        youtube = url;
        break;
      case 'SPOTIFY':
        spotify = url;
        break;
      case 'TIKTOK':
        tiktok = url;
        break;
      case 'SOUNDCLOUD':
        soundcloud = url;
        break;
    }
  }

  return ProfileDto(
    id: profile.id,
    userName: profile.userName,
    displayName: profile.displayName,
    email: profile.email,
    role: profile.role,
    bio: profile.bio,
    city: profile.city,
    country: profile.country,
    profileImagePath: profile.profileImagePath,
    coverImagePath: profile.coverImagePath,
    followersCount: profile.followersCount,
    followingCount: profile.followingCount,
    tracksCount: profile.tracksCount,
    likesReceived: profile.likesReceived,
    visibility: profile.visibility,
    userType: profile.userType,
    isActive: profile.isActive,
    isVerified: profile.isVerified,
    instagram: instagram,
    twitter: twitter,
    youtube: youtube,
    spotify: spotify,
    tiktok: tiktok,
    soundcloud: soundcloud,
  );
}
}
///logic for me to remember the flow:
// Call 1 → GET /users/1
// Returns: name, bio, location, followers etc.
// no instagram, twitter, website

// Call 2 → GET /social_links/1  
// Returns: instagram, twitter, website
// no name, bio, location etc.
//the merge combines both into one Profiledto

// When real backend is ready — if the backend changes to 
// return everything in one call, 
// I just delete the second call in repository_impl 
// and remove mergeSocialLinks. 
// The rest of the app doesn't change.
