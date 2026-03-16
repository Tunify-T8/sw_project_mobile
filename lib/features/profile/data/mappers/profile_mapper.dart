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
      userName: user['username'] ?? '',
      bio: user['bio'] ?? '',
      city: city,
      country: country,
      profileImagePath: user['avatarUrl'],
      coverImagePath: user['coverUrl'],
      followersCount: user['followersCount'] ?? 0,
      followingCount: user['followingCount'] ?? 0,
      userType: user['userType'] ?? 'ARTIST',
      visibility: user['visibility'] ?? 'PUBLIC',
      instagram: null, // comes from social_links call
      twitter: null,   // comes from social_links call
      website: null,   // comes from social_links call
    );
  }

  static ProfileDto mergeSocialLinks(
    ProfileDto profile,
    Map<String, dynamic> socialJson,
  ) {
    // MockAPI returns directly, real backend returns { "socialLinks": { ... } }
    final links = socialJson['socialLinks'] ?? socialJson;

    return ProfileDto(
      userName: profile.userName,
      bio: profile.bio,
      city: profile.city,
      country: profile.country,
      profileImagePath: profile.profileImagePath,
      coverImagePath: profile.coverImagePath,
      followersCount: profile.followersCount,
      followingCount: profile.followingCount,
      visibility: profile.visibility,
      userType: profile.userType,
      instagram: links['instagram'],
      twitter: links['twitter'],
      website: links['website'],
    );
  }
}
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