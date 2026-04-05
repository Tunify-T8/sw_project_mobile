import '../../data/dto/profile_dto.dart';

abstract class ProfileRepository {
  Future<ProfileDto> getProfile();
  Future<ProfileDto> getProfileById(String userIdOrUsername);
  Future<ProfileDto> updateProfile(ProfileDto profile);
}
