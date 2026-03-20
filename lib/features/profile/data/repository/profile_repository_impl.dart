import '../../../../core/storage/token_storage.dart';
import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../dto/profile_dto.dart';
import '../../domain/repositories/profile_repository.dart';
import '../api/profile_api.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    TokenStorage tokenStorage = const TokenStorage(),
    GlobalTrackStore? trackStore,
    ProfileApi? profileApi,
  })  : _tokenStorage = tokenStorage,
        _trackStore = trackStore ?? GlobalTrackStore.instance,
        _profileApi = profileApi ?? ProfileApi();

  final TokenStorage _tokenStorage;
  final GlobalTrackStore _trackStore;
  final ProfileApi _profileApi;

  @override
  Future<ProfileDto> getProfile() async {
    final user = await _tokenStorage.getUser();
    if (user == null) throw Exception('No authenticated user found.');

    return await _profileApi.getProfile(user.id);
  }

  @override
  Future<ProfileDto> updateProfile(ProfileDto profile) async {
    final user = await _tokenStorage.getUser();
    if (user == null) throw Exception('No authenticated user found.');

    return await _profileApi.updateProfile(user.id, profile);
  }
}