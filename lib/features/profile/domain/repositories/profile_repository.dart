import '../../data/dto/profile_dto.dart';

abstract class ProfileRepository {
  Future<ProfileDto> getProfile();
  Future<ProfileDto> updateProfile(ProfileDto profile);
}
