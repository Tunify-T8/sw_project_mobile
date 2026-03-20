import 'package:dio/dio.dart';
import '../dto/profile_dto.dart';
import '../mappers/profile_mapper.dart';

class ProfileApi {
  ProfileApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl =
      'https://69b5b11a583f543fbd9c3072.mockapi.io';

  Future<ProfileDto> getProfile(String userId) async {
    // Call 1: GET /users/1
    final userRes = await _dio.get('$_baseUrl/users/1');

    // MockAPI returns an array, get first item
    final data = userRes.data is List
        ? userRes.data[0]
        : userRes.data;

    ProfileDto profile = ProfileMapper.fromJson(data);

    // Call 2: GET /social_links/1
    try {
      final socialRes = await _dio.get('$_baseUrl/social_links/1');
      final socialData = socialRes.data is List
          ? socialRes.data[0]
          : socialRes.data;
      profile = ProfileMapper.mergeSocialLinks(profile, socialData);
    } catch (_) {
      // social_links may not exist yet, that's ok
    }

    return profile;
  }

  Future<ProfileDto> updateProfile(
      String userId, ProfileDto profile) async {
    // Update /users/1
    await _dio.put('$_baseUrl/users/1', data: {
      'username': profile.userName,
      'displayName': profile.displayName,
      'bio': profile.bio,
      'location': '${profile.city}, ${profile.country}',
      'avatarUrl': profile.profileImagePath,
      'coverUrl': profile.coverImagePath,
      'visibility': profile.visibility,
      'userType': profile.userType,
    });

    // Update /social_links/1
    await _dio.put('$_baseUrl/social_links/1', data: {
      'instagram': profile.instagram,
      'twitter': profile.twitter,
      'website': profile.website,
    });

    return getProfile(userId);
  }
}