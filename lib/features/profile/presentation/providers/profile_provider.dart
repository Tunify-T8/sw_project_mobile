import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../data/dto/profile_dto.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUsecase _getProfileUsecase = GetProfileUsecase(
    ProfileRepositoryImpl(),
  );

  ProfileNotifier() : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final profile = await _getProfileUsecase.execute();
      state = state.copyWith(status: ProfileStatus.success, profile: profile);
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile(ProfileDto updatedDto) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      await ProfileRepositoryImpl().updateProfile(updatedDto);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(status: ProfileStatus.error, errorMessage: e.toString());
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);