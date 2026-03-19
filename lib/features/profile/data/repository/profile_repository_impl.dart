import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dto/profile_dto.dart';
import '../mappers/profile_mapper.dart';
import '../../domain/repositories/profile_repository.dart';
//this file: goes to backend fetches raw json data

//when real backend is ready:
//1)make usemock=false->baseurl will be that of actual backend
//2)Right now no token is needed for MockAPI. 
//When real backend is ready I'll get the token from wherever it is
// saved (SharedPreferences) and add it to headers




class ProfileRepositoryImpl implements ProfileRepository {
  // Toggle this when real backend is ready
  static const bool useMock = true;
    // static const bool useMock = false; //when I et the real api that is what will change
    // // calls localhost:3000/users/me with real token
  static const String mockBaseUrl = 'https://69b5b11a583f543fbd9c3072.mockapi.io';
  static const String realBaseUrl = 'http://localhost:3000';
    //if usemock is false it will use actual api; and will be baseurl used for everything
  String get baseUrl => useMock ? mockBaseUrl : realBaseUrl;

  @override
  Future<ProfileDto> getProfile() async {
    // Step 1 — get profile
    final profileRes = await http.get(
      Uri.parse(useMock ? '$baseUrl/users/1' : '$baseUrl/users/me'),
    );
    if (profileRes.statusCode != 200) {
      throw Exception('Failed to load profile: ${profileRes.statusCode}');
    }
    final profileJson = jsonDecode(profileRes.body);

    ProfileDto profile = ProfileMapper.fromJson(profileJson);

    // Step 2 — get social links
    final socialRes = await http.get(
      Uri.parse(useMock ? '$baseUrl/social_links/1' : '$baseUrl/users/me/social-links'),
    );
    if (socialRes.statusCode != 200) {
      throw Exception('Failed to load social links: ${socialRes.statusCode}');
    }

    final socialJson = jsonDecode(socialRes.body);

    // Step 3 — merge and return
    return ProfileMapper.mergeSocialLinks(profile, socialJson);
  }

    @override
    @override
Future<ProfileDto> updateProfile(ProfileDto profile) async {
  if (useMock) {
    final res1 = await http.patch(
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
    if (res1.statusCode != 200) {
      throw Exception('Failed to update profile: ${res1.statusCode}');
    }

    final res2 = await http.patch(
      Uri.parse('$baseUrl/social_links/1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'instagram': profile.instagram,
        'twitter': profile.twitter,
        'website': profile.website,
      }),
    );
    if (res2.statusCode != 200) {
      throw Exception('Failed to update social links: ${res2.statusCode}');
    }
  } else {
    final res1 = await http.patch(
      Uri.parse('$baseUrl/users/me/profile'),
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
    if (res1.statusCode != 200) {
      throw Exception('Failed to update profile: ${res1.statusCode}');
    }

    final res2 = await http.patch(
      Uri.parse('$baseUrl/users/me/social-links'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'instagram': profile.instagram,
        'twitter': profile.twitter,
        'website': profile.website,
      }),
    );
    if (res2.statusCode != 200) {
      throw Exception('Failed to update social links: ${res2.statusCode}');
    }
  }

  return profile;
}
}