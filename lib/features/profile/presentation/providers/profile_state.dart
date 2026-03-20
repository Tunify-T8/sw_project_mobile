import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get isSuccess => status == ProfileStatus.success;
  bool get isError => status == ProfileStatus.error;
}
