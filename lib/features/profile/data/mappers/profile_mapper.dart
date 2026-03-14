import '../dto/profile_dto.dart';

class ProfileMapper {
  static ProfileDto fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    // Split "New York, United States" → city: "New York", country: "United States"
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
      instagram: null,  // comes from /users/me/social-links
      twitter: null,    // comes from /users/me/social-links
      website: null,    // comes from /users/me/social-links
    );
  }
}