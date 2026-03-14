import 'package:flutter/material.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../data/dto/profile_dto.dart';
import 'profile_state.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUsecase _getProfileUsecase = GetProfileUsecase(
    ProfileRepositoryImpl(),
  );

  ProfileState state = const ProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    notifyListeners();

    try {
      final profile = await _getProfileUsecase.execute();
      state = state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> updateProfile(ProfileDto updatedDto) async {
    state = state.copyWith(status: ProfileStatus.loading);
    notifyListeners();

    try {
      await ProfileRepositoryImpl().updateProfile(updatedDto);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }
}