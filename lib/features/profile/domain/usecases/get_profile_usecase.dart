import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../data/dto/profile_dto.dart';

class GetProfileUsecase {
  final ProfileRepository repository;

  GetProfileUsecase(this.repository);

  Future<ProfileEntity> execute() async {
    final ProfileDto dto = await repository.getProfile();

    // Convert DTO → Entity
    return ProfileEntity(
      userName: dto.userName,
      city: dto.city,
      country: dto.country,
      bio: dto.bio,
      profileImagePath: dto.profileImagePath,
      coverImagePath: dto.coverImagePath,
      instagram: dto.instagram,
      twitter: dto.twitter,
      website: dto.website,
      followersCount: dto.followersCount,
      followingCount: dto.followingCount,
      visibility: dto.visibility,
      userType: dto.userType,
    );
  }
}