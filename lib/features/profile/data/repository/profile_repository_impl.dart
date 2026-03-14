import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dto/profile_dto.dart';
import '../mappers/profile_mapper.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  // Toggle this when real backend is ready
  static const bool useMock = true;

  static const String mockBaseUrl = 'https://69b5b11a583f543fbd9c3072.mockapi.io';
  static const String realBaseUrl = 'http://localhost:3000';

  String get baseUrl => useMock ? mockBaseUrl : realBaseUrl;

  @override
  Future<ProfileDto> getProfile() async {
    // Step 1 — get profile
    final profileRes = await http.get(
      Uri.parse(useMock ? '$baseUrl/users/1' : '$baseUrl/users/me'),
    );

    final profileJson = jsonDecode(profileRes.body);
    ProfileDto profile = ProfileMapper.fromJson(profileJson);

    // Step 2 — get social links
    final socialRes = await http.get(
      Uri.parse(useMock ? '$baseUrl/social_links/1' : '$baseUrl/users/me/social-links'),
    );

    final socialJson = jsonDecode(socialRes.body);

    // Step 3 — merge and return
    return ProfileMapper.mergeSocialLinks(profile, socialJson);
  }

    @override
    Future<ProfileDto> updateProfile(ProfileDto profile) async {
    if (useMock) {
        // MockAPI — just PATCH /users/1
        await http.patch(
        Uri.parse('$baseUrl/users/1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
            'username': profile.userName,
            'bio': profile.bio,
            'location': '${profile.city}, ${profile.country}',
            'avatarUrl': profile.profileImagePath,
            'coverUrl': profile.coverImagePath,
            'visibility': profile.visibility,
            'userType': profile.userType,
        }),
        );

        // MockAPI — PATCH social links
        await http.patch(
        Uri.parse('$baseUrl/social_links/1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
            'instagram': profile.instagram,
            'twitter': profile.twitter,
            'website': profile.website,
        }),
        );
    } else {
        // Real backend
        await http.patch(
        Uri.parse('$baseUrl/users/me/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
            'username': profile.userName,
            'bio': profile.bio,
            'location': '${profile.city}, ${profile.country}',
            'avatarUrl': profile.profileImagePath,
            'coverUrl': profile.coverImagePath,
            'visibility': profile.visibility,
        }),
        );

        await http.patch(
        Uri.parse('$baseUrl/users/me/social-links'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
            'instagram': profile.instagram,
            'twitter': profile.twitter,
            'website': profile.website,
        }),
        );
    }

    return profile;
    }
}