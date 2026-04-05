import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_by_id_usecase.dart';
import 'profile_provider.dart';
import 'profile_state.dart';

class UserProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _repository = ref.read(
    profileRepositoryProvider,
  );
  late final GetProfileByIdUsecase _getProfileByIdUsecase = GetProfileByIdUsecase(
    _repository,
  );

  String? _currentUserId;

  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> loadProfile(String userIdOrUsername) async {
    if (_currentUserId == userIdOrUsername && state.status == ProfileStatus.success) {
      // Already loaded this user's profile
      return;
    }

    _currentUserId = userIdOrUsername;
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final profile = await _getProfileByIdUsecase.execute(userIdOrUsername);
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

  void clearProfile() {
    _currentUserId = null;
    state = const ProfileState();
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, ProfileState>(
  UserProfileNotifier.new,
);