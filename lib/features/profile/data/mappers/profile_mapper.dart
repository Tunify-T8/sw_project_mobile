import '../dto/profile_dto.dart';

class ProfileMapper {
  static ProfileDto fromJson(Map<String, dynamic> json) {
    // MockAPI returns the object directly (no 'user' wrapper)
    // Real backend returns { "user": { ... } } so we handle both
    final user = json['user'] ?? json;

    // Split "Cairo, Egypt" → city: "Cairo", country: "Egypt"
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
      instagram: links['instagram'],
      twitter: links['twitter'],
      website: links['website'],
    );
  }
}