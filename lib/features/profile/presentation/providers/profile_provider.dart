import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/dto/profile_dto.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _repository = ref.read(
    profileRepositoryProvider,
  );
  late final GetProfileUsecase _getProfileUsecase = GetProfileUsecase(
    _repository,
  );

  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final profile = await _getProfileUsecase.execute();
      state = state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateProfile(ProfileDto updatedDto) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final updatedProfile = await _repository.updateProfile(updatedDto);
      await ref
          .read(authControllerProvider.notifier)
          .syncProfileIdentity(
            username: updatedProfile.userName,
            avatarUrl: updatedProfile.profileImagePath,
          );
      await loadProfile();
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    tokenStorage: ref.read(tokenStorageProvider),
    trackStore: ref.read(globalTrackStoreProvider),
  );
});

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
