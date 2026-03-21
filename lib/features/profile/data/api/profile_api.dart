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
      final socialData = socialRes.data is List
          ? socialRes.data[0]
          : socialRes.data;
      profile = ProfileMapper.mergeSocialLinks(profile, socialData);
    } catch (_) {}

    return profile;
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
      //'userType': profile.userType,
    });

    await _dio.patch(ApiEndpoints.updateSocialLinks, data: {
      'instagram': profile.instagram,
      'twitter': profile.twitter,
      'website': profile.website,
    });

    return getProfile(userId);
  }
}