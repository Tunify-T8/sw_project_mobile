import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';
import '../../data/dto/profile_dto.dart';

class GetProfileByIdUsecase {
  final ProfileRepository repository;

  GetProfileByIdUsecase(this.repository);

  Future<ProfileEntity> execute(String userIdOrUsername) async {
    final ProfileDto dto = await repository.getProfileById(userIdOrUsername);

    return ProfileEntity(
      id: dto.id,
      userName: dto.userName,
      displayName: dto.displayName,
      email: dto.email,  // May be null for public profiles
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
      followersCount: dto.followersCount,  // May be null for private profiles
      followingCount: dto.followingCount,
      tracksCount: dto.tracksCount,
      likesReceived: dto.likesReceived,
      visibility: dto.visibility,
      userType: dto.userType,
      isActive: dto.isActive,
      isCertified: dto.isCertified,
    );
  }
}