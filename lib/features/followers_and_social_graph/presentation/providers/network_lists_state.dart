import '../../domain/entities/social_user_entity.dart';

class NetworkListsState {
  final List<SocialUserEntity> followingUsers;
  final List<SocialUserEntity> followersUsers;
  final List<SocialUserEntity> suggestedUsers;
  final List<SocialUserEntity> blockedUsers;
  final List<SocialUserEntity> mutualUsers;

  final bool isLoadingFollowing;
  final bool isLoadingFollowers;
  final bool isLoadingSuggested;
  final bool isLoadingBlocked;
  final bool isLoadingMutual;

  final String? error;

  const NetworkListsState({
    this.followingUsers = const [],
    this.followersUsers = const [],
    this.suggestedUsers = const [],
    this.blockedUsers = const [],
    this.mutualUsers = const [],
    this.isLoadingFollowing = false,
    this.isLoadingFollowers = false,
    this.isLoadingSuggested = false,
    this.isLoadingBlocked = false,
    this.isLoadingMutual = false,
    this.error,
  });

  NetworkListsState copyWith({
    List<SocialUserEntity>? followingUsers,
    List<SocialUserEntity>? followersUsers,
    List<SocialUserEntity>? suggestedUsers,
    List<SocialUserEntity>? blockedUsers,
    List<SocialUserEntity>? mutualUsers,
    bool? isLoadingFollowing,
    bool? isLoadingFollowers,
    bool? isLoadingSuggested,
    bool? isLoadingBlocked,
    bool? isLoadingMutual,
    String? error,
  }) {
    return NetworkListsState(
      followingUsers: followingUsers ?? this.followingUsers,
      followersUsers: followersUsers ?? this.followersUsers,
      suggestedUsers: suggestedUsers ?? this.suggestedUsers,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      mutualUsers: mutualUsers ?? this.mutualUsers,
      isLoadingFollowing: isLoadingFollowing ?? this.isLoadingFollowing,
      isLoadingFollowers: isLoadingFollowers ?? this.isLoadingFollowers,
      isLoadingSuggested: isLoadingSuggested ?? this.isLoadingSuggested,
      isLoadingBlocked: isLoadingBlocked ?? this.isLoadingBlocked,
      isLoadingMutual: isLoadingMutual ?? this.isLoadingMutual,
      error: error,
    );
  }
}