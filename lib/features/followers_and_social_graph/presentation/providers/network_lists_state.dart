import '../../domain/entities/social_user_entity.dart';

class NetworkListsState {
  final List<SocialUserEntity> following;
  final List<SocialUserEntity> followers;
  final List<SocialUserEntity> suggestedUsers;
  final List<SocialUserEntity> blockedUsers;
  final List<SocialUserEntity> mutualFriends;
  final bool isLoading;
  final String? error;
  final bool hasLoadedOnce;

  const NetworkListsState({
    this.following = const [],
    this.followers = const [],
    this.suggestedUsers = const [],
    this.blockedUsers = const [],
    this.mutualFriends = const [],
    this.isLoading = false,
    this.error,
    this.hasLoadedOnce = false,
  });

  NetworkListsState copyWith({
    List<SocialUserEntity>? following,
    List<SocialUserEntity>? followers,
    List<SocialUserEntity>? suggestedUsers,
    List<SocialUserEntity>? blockedUsers,
    List<SocialUserEntity>? mutualFriends,
    bool? isLoading,
    String? error,
    bool? hasLoadedOnce,
  }) {
    return NetworkListsState(
      following: following ?? this.following,
      followers: followers ?? this.followers,
      suggestedUsers: suggestedUsers ?? this.suggestedUsers,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      mutualFriends: mutualFriends ?? this.mutualFriends,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }
}