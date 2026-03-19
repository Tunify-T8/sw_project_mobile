import '../../../../core/storage/token_storage.dart';
import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../auth/domain/entities/auth_user_entity.dart';
import '../dto/profile_dto.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    TokenStorage tokenStorage = const TokenStorage(),
    GlobalTrackStore? trackStore,
  }) : _tokenStorage = tokenStorage,
       _trackStore = trackStore ?? GlobalTrackStore.instance;

  static final Map<String, ProfileDto> _profilesByUserId = {};

  final TokenStorage _tokenStorage;
  final GlobalTrackStore _trackStore;

  @override
  Future<ProfileDto> getProfile() async {
    final user = await _tokenStorage.getUser();
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    return _mergeProfileForUser(user);
  }

  @override
  Future<ProfileDto> updateProfile(ProfileDto profile) async {
    final user = await _tokenStorage.getUser();
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    _profilesByUserId[user.id] = ProfileDto(
      id: user.id,
      email: user.email,
      role: user.role,
      userName: profile.userName,
      displayName: profile.displayName,
      bio: profile.bio,
      city: profile.city,
      country: profile.country,
      profileImagePath: profile.profileImagePath,
      coverImagePath: profile.coverImagePath,
      instagram: profile.instagram,
      twitter: profile.twitter,
      website: profile.website,
      followersCount: profile.followersCount,
      followingCount: profile.followingCount,
      tracksCount: _visibleUploadsCount(user.id),
      likesReceived: profile.likesReceived,
      visibility: profile.visibility,
      userType: profile.userType,
      isActive: profile.isActive,
      isVerified: user.isVerified,
    );

    return _mergeProfileForUser(
      AuthUserEntity(
        id: user.id,
        email: user.email,
        username: profile.userName,
        role: user.role,
        isVerified: user.isVerified,
        avatarUrl: profile.profileImagePath,
      ),
    );
  }

  ProfileDto _mergeProfileForUser(AuthUserEntity user) {
    final saved = _profilesByUserId[user.id];

    return ProfileDto(
      id: user.id,
      email: user.email,
      role: user.role,
      userName: user.username,
      displayName: saved?.displayName,
      bio: saved?.bio ?? '',
      city: saved?.city ?? '',
      country: saved?.country ?? '',
      profileImagePath: saved?.profileImagePath ?? user.avatarUrl,
      coverImagePath: saved?.coverImagePath,
      instagram: saved?.instagram,
      twitter: saved?.twitter,
      website: saved?.website,
      followersCount: saved?.followersCount ?? 0,
      followingCount: saved?.followingCount ?? 0,
      tracksCount: _visibleUploadsCount(user.id),
      likesReceived: saved?.likesReceived ?? 0,
      visibility: saved?.visibility ?? 'PUBLIC',
      userType: saved?.userType ?? _defaultUserType(user.role),
      isActive: saved?.isActive ?? true,
      isVerified: user.isVerified,
    );
  }

  int _visibleUploadsCount(String userId) {
    return _trackStore
        .allForUser(userId)
        .where((track) => !track.isDeleted)
        .length;
  }

  String _defaultUserType(String role) {
    return role.toUpperCase() == 'ARTIST' ? 'ARTIST' : 'LISTENER';
  }
}
