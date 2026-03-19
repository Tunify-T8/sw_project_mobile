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
      website: null,
    );
}

  static ProfileDto mergeSocialLinks(
    ProfileDto profile,
    Map<String, dynamic> socialJson,
  ) {
    // MockAPI returns directly, real backend returns { "socialLinks": { ... } }
    final links = socialJson['socialLinks'] ?? socialJson;

    return ProfileDto(
      id: profile.id,                        // added after BE changed
      userName: profile.userName,
      displayName: profile.displayName,      // added after BE changed
      email: profile.email,                  // added after BE changed
      role: profile.role,                   //added after BE changed
      bio: profile.bio,
      city: profile.city,
      country: profile.country,
      profileImagePath: profile.profileImagePath,
      coverImagePath: profile.coverImagePath,
      followersCount: profile.followersCount,
      followingCount: profile.followingCount,
      tracksCount: profile.tracksCount,      // added after BE changed
      likesReceived: profile.likesReceived,  // added after BE changed
      visibility: profile.visibility,
      userType: profile.userType,
      isActive: profile.isActive,            // added after BE changed
      isVerified: profile.isVerified,        // added after BE changed
      instagram: links['instagram'],
      twitter: links['twitter'],
      website: links['website'],
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