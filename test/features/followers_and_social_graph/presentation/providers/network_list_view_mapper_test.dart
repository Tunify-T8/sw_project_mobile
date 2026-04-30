import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/network_lists_state.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/utils/network_list_view_mapper.dart';

void main() {
  test('getTitle returns labels for all list types', () {
    expect(NetworkListViewMapper.getTitle(NetworkListType.following), 'Following');
    expect(NetworkListViewMapper.getTitle(NetworkListType.followers), 'Followers');
    expect(NetworkListViewMapper.getTitle(NetworkListType.suggestedUsers), 'Suggested Users');
    expect(NetworkListViewMapper.getTitle(NetworkListType.suggestedArtists), 'Suggested Artists');
    expect(NetworkListViewMapper.getTitle(NetworkListType.blocked), 'Blocked Users');
    expect(NetworkListViewMapper.getTitle(NetworkListType.trueFriends), 'Your true friends');
  });

  test('getUsers returns the selected list or an empty list', () {
    const user = SocialUserEntity(id: 'u1', username: 'one');
    const state = NetworkListsState(
      userLists: {
        NetworkListType.followers: [user],
      },
    );

    expect(NetworkListViewMapper.getUsers(NetworkListType.followers, state), [user]);
    expect(NetworkListViewMapper.getUsers(NetworkListType.following, state), isEmpty);
  });

  test('shouldShowTrueFriends only for my following list', () {
    expect(
      NetworkListViewMapper.shouldShowTrueFriends(
        listType: NetworkListType.following,
        isMyProfile: true,
      ),
      isTrue,
    );
    expect(
      NetworkListViewMapper.shouldShowTrueFriends(
        listType: NetworkListType.followers,
        isMyProfile: true,
      ),
      isFalse,
    );
    expect(
      NetworkListViewMapper.shouldShowTrueFriends(
        listType: NetworkListType.following,
        isMyProfile: false,
      ),
      isFalse,
    );
  });

  test('loadInitialData dispatches to the matching notifier method', () async {
    final notifier = FakeNetworkListNotifier();

    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.following,
      userId: null,
      isMyProfile: true,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.following,
      userId: 'other',
      isMyProfile: false,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.followers,
      userId: null,
      isMyProfile: true,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.followers,
      userId: 'other',
      isMyProfile: false,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.suggestedUsers,
      isMyProfile: true,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.suggestedArtists,
      isMyProfile: true,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.blocked,
      isMyProfile: true,
      notifier: notifier,
    );
    await NetworkListViewMapper.loadInitialData(
      listType: NetworkListType.trueFriends,
      isMyProfile: true,
      notifier: notifier,
    );

    expect(notifier.calls, [
      'loadMyFollowing',
      'loadFollowingList:other',
      'loadMyFollowers',
      'loadFollowersList:other',
      'loadSuggestedUsers',
      'loadSuggestedArtists',
      'loadBlockedUsers',
      'loadTrueFriends',
    ]);
  });
}

class FakeNetworkListNotifier {
  final calls = <String>[];

  Future<void> loadMyFollowing() async => calls.add('loadMyFollowing');
  Future<void> loadFollowingList({required String userId}) async {
    calls.add('loadFollowingList:$userId');
  }

  Future<void> loadMyFollowers() async => calls.add('loadMyFollowers');
  Future<void> loadFollowersList({required String userId}) async {
    calls.add('loadFollowersList:$userId');
  }

  Future<void> loadSuggestedUsers() async => calls.add('loadSuggestedUsers');
  Future<void> loadSuggestedArtists() async => calls.add('loadSuggestedArtists');
  Future<void> loadBlockedUsers() async => calls.add('loadBlockedUsers');
  Future<void> loadTrueFriends() async => calls.add('loadTrueFriends');
}
