import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../data/dto/profile_dto.dart';

class GetProfileUsecase {
  final ProfileRepository repository;

  GetProfileUsecase(this.repository);

  Future<ProfileEntity> execute() async {
    final ProfileDto dto = await repository.getProfile();

    return ProfileEntity(
      id: dto.id,
      userName: dto.userName,
      displayName: dto.displayName,
      email: dto.email,
      role: dto.role,
      bio: dto.bio,
      city: dto.city,
      country: dto.country,
      profileImagePath: dto.profileImagePath,
      coverImagePath: dto.coverImagePath,
      instagram: dto.instagram,
      twitter: dto.twitter,
      youtube: dto.youtube,
      spotify: dto.spotify,
      tiktok: dto.tiktok,
      soundcloud: dto.soundcloud,
      followersCount: dto.followersCount,
      followingCount: dto.followingCount,
      tracksCount: dto.tracksCount,
      likesReceived: dto.likesReceived,
      visibility: dto.visibility,
      userType: dto.userType,
      isActive: dto.isActive,
      isVerified: dto.isVerified,
    );
  }
}
