import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../dto/profile_dto.dart';
import '../mappers/profile_mapper.dart';

class ProfileApi {
  ProfileApi({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<ProfileDto> getProfile(String userId) async {
    final userRes = await _dio.get(ApiEndpoints.getProfile);

    final data = userRes.data is List
        ? userRes.data[0]
        : userRes.data;

    ProfileDto profile = ProfileMapper.fromJson(data);

    try {
      final socialRes = await _dio.get(ApiEndpoints.getSocialLinks);
      final socialData = {'links': socialRes.data is List ? socialRes.data : [socialRes.data]};
      profile = ProfileMapper.mergeSocialLinks(profile, socialData);
    } catch (e) {
      print('*** SOCIAL ERROR: $e ***');
    }

    return profile;
  }

    Future<void> deleteSocialLink(String platform) async {
      await _dio.delete('/users/me/social-links/${platform.toLowerCase()}');
    }
  Future<ProfileDto> updateProfile(
      String userId, ProfileDto profile) async {
    await _dio.patch(ApiEndpoints.updateProfile, data: {
      'username': profile.userName,
      'displayName': profile.displayName,
      'bio': profile.bio,
      'location': '${profile.city}, ${profile.country}',
      'avatarUrl': profile.profileImagePath,
      'coverUrl': profile.coverImagePath,
      'visibility': profile.visibility,
      'role': profile.userType, 
    });

   final links = [
    if (profile.instagram != null && profile.instagram!.isNotEmpty)
      {'platform': 'INSTAGRAM', 'url': profile.instagram},
    if (profile.twitter != null && profile.twitter!.isNotEmpty)
      {'platform': 'TWITTER', 'url': profile.twitter},
    if (profile.youtube != null && profile.youtube!.isNotEmpty)
      {'platform': 'YOUTUBE', 'url': profile.youtube},
    if (profile.spotify != null && profile.spotify!.isNotEmpty)
      {'platform': 'SPOTIFY', 'url': profile.spotify},
    if (profile.tiktok != null && profile.tiktok!.isNotEmpty)
      {'platform': 'TIKTOK', 'url': profile.tiktok},
    if (profile.soundcloud != null && profile.soundcloud!.isNotEmpty)
      {'platform': 'SOUNDCLOUD', 'url': profile.soundcloud},
  ];

  if (links.isNotEmpty) {
    await _dio.patch(ApiEndpoints.updateSocialLinks, data: {'links': links});
  }
 
  final toDelete = <String>[];  // Links to delete->if left to be null or''
  if (profile.instagram == null || profile.instagram!.isEmpty) toDelete.add('instagram');
  if (profile.twitter == null || profile.twitter!.isEmpty) toDelete.add('twitter');
  if (profile.youtube == null || profile.youtube!.isEmpty) toDelete.add('youtube');
  if (profile.spotify == null || profile.spotify!.isEmpty) toDelete.add('spotify');
  if (profile.tiktok == null || profile.tiktok!.isEmpty) toDelete.add('tiktok');
  if (profile.soundcloud == null || profile.soundcloud!.isEmpty) toDelete.add('soundcloud');

  for (final platform in toDelete) {
    try {
      await deleteSocialLink(platform);
    } catch (_) {
      // ignore this if link doesn't exist->check with BE
    }
  }

  return getProfile(userId);
}
}