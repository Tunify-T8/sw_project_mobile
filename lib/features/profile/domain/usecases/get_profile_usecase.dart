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
      email: dto.email ?? '',  // Provide default for current user profile
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
      followersCount: dto.followersCount ?? 0,  // Provide defaults
      followingCount: dto.followingCount ?? 0,
      tracksCount: dto.tracksCount ?? 0,
      likesReceived: dto.likesReceived ?? 0,
      visibility: dto.visibility ?? 'PUBLIC',
      userType: dto.userType,
      isActive: dto.isActive ?? true,
      isCertified: dto.isCertified ?? false,
    );
  }
}
