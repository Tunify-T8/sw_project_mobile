import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/network_list_type.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/network_lists_state.dart';

void main() {
  test('copyWith replaces only supplied maps', () {
    const original = NetworkListsState();
    final users = {
      NetworkListType.followers: const [
        SocialUserEntity(id: 'u1', username: 'one'),
      ],
    };

    final copied = original.copyWith(userLists: users);

    expect(copied.userLists, users);
    expect(copied.isLoading, original.isLoading);
    expect(copied.error, original.error);
    expect(copied.hasLoadedOnce, original.hasLoadedOnce);
  });

  test('updateListState updates list loading error and loaded flags independently', () {
    const original = NetworkListsState();
    final updated = original.updateListState(
      type: NetworkListType.following,
      users: const [SocialUserEntity(id: 'u2', username: 'two')],
      isLoading: false,
      error: 'problem',
      hasLoadedOnce: true,
    );

    expect(updated.userLists[NetworkListType.following]!.single.id, 'u2');
    expect(updated.isLoading[NetworkListType.following], isFalse);
    expect(updated.error[NetworkListType.following], 'problem');
    expect(updated.hasLoadedOnce[NetworkListType.following], isTrue);
    expect(updated.isLoading[NetworkListType.followers], isTrue);
  });
}
