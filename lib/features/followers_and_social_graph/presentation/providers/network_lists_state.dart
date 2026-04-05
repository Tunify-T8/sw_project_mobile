import '../../domain/entities/social_user_entity.dart';
import '../../domain/entities/network_list_type.dart';

class NetworkListsState {
  final Map<NetworkListType, List<SocialUserEntity>> userLists;
  final Map<NetworkListType, bool> isLoading;
  final Map<NetworkListType, String?> error;
  final Map<NetworkListType, bool> hasLoadedOnce;

  const NetworkListsState({
    this.userLists = const {},
    this.isLoading = const {
      NetworkListType.following: true,
      NetworkListType.followers: true,
      NetworkListType.suggestedUsers: true,
      NetworkListType.suggestedArtists: true,
      NetworkListType.blocked: true,
      NetworkListType.trueFriends: true,
    },
    this.error = const {},
    this.hasLoadedOnce = const {
      NetworkListType.following: false,
      NetworkListType.followers: false,
      NetworkListType.suggestedUsers: false,
      NetworkListType.suggestedArtists: false,
      NetworkListType.blocked: false,
      NetworkListType.trueFriends: false,
    },
  });

  NetworkListsState copyWith({
    Map<NetworkListType, List<SocialUserEntity>>? userLists,
    Map<NetworkListType, bool>? isLoading,
    Map<NetworkListType, String?>? error,
    Map<NetworkListType, bool>? hasLoadedOnce,
  }) {
    return NetworkListsState(
      userLists: userLists ?? this.userLists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  NetworkListsState updateListState(
    { required NetworkListType type, 
    List<SocialUserEntity>? users,
    bool? isLoading,
    String? error,
    bool? hasLoadedOnce,
  }) {
    return NetworkListsState(
      userLists: {...userLists, if (users != null) type: users},
      isLoading: {...this.isLoading, if (isLoading != null) type: isLoading},
      error: {...this.error, type: error},
      hasLoadedOnce: {
        ...this.hasLoadedOnce,
        if (hasLoadedOnce != null) type: hasLoadedOnce,
      },
    );
  }
}
