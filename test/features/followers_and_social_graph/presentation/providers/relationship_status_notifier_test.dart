import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/relationship_status_notifier.dart';
import 'package:software_project/features/followers_and_social_graph/presentation/providers/social_graph_repository_provider.dart';

void main() {
  late FakeRelationshipRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeRelationshipRepository();
    container = ProviderContainer(
      overrides: [socialGraphRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads relationship status on build', () async {
    repository.relation = const SocialRelationEntity(
      targetUserId: 'user-1',
      isFollowing: true,
      isBlocked: true,
    );

    container.read(relationshipStatusProvider('user-1'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(relationshipStatusProvider('user-1'));
    expect(repository.statusCalls, ['user-1']);
    expect(state.isFollowing, isTrue);
    expect(state.isBlocked, isTrue);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('records load errors', () async {
    repository.error = Exception('status failed');

    container.read(relationshipStatusProvider('user-2'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(relationshipStatusProvider('user-2'));
    expect(state.isLoading, isFalse);
    expect(state.error, 'Exception: status failed');
  });

  test('toggleFollow follows and unfollows optimistically', () async {
    repository.relation = const SocialRelationEntity(
      targetUserId: 'user-3',
      isFollowing: false,
    );

    final notifier = container.read(relationshipStatusProvider('user-3').notifier);
    await Future<void>.delayed(Duration.zero);

    await notifier.toggleFollow();
    expect(container.read(relationshipStatusProvider('user-3')).isFollowing, isTrue);
    expect(repository.followed, ['user-3']);

    await notifier.toggleFollow();
    expect(container.read(relationshipStatusProvider('user-3')).isFollowing, isFalse);
    expect(repository.unfollowed, ['user-3']);
  });

  test('toggleFollow rolls back when repository action fails', () async {
    repository.relation = const SocialRelationEntity(
      targetUserId: 'user-4',
      isFollowing: false,
    );

    final notifier = container.read(relationshipStatusProvider('user-4').notifier);
    await Future<void>.delayed(Duration.zero);
    repository.error = Exception('follow failed');

    await notifier.toggleFollow();

    final state = container.read(relationshipStatusProvider('user-4'));
    expect(state.isFollowing, isFalse);
    expect(state.error, 'Exception: follow failed');
  });

  test('toggleBlock blocks and unblocks optimistically', () async {
    repository.relation = const SocialRelationEntity(
      targetUserId: 'user-5',
      isFollowing: false,
      isBlocked: false,
    );

    final notifier = container.read(relationshipStatusProvider('user-5').notifier);
    await Future<void>.delayed(Duration.zero);

    await notifier.toggleBlock();
    expect(container.read(relationshipStatusProvider('user-5')).isBlocked, isTrue);
    expect(repository.blocked, ['user-5']);

    await notifier.toggleBlock();
    expect(container.read(relationshipStatusProvider('user-5')).isBlocked, isFalse);
    expect(repository.unblocked, ['user-5']);
  });

  test('toggle methods do nothing until the corresponding status is known', () async {
    final notifier = container.read(relationshipStatusProvider('unknown').notifier);
    await notifier.toggleFollow();
    await notifier.toggleBlock();

    expect(repository.followed, isEmpty);
    expect(repository.blocked, isEmpty);
  });
}

class FakeRelationshipRepository implements SocialGraphRepository {
  Object? error;
  SocialRelationEntity relation = const SocialRelationEntity(
    targetUserId: 'default',
    isFollowing: false,
  );
  final statusCalls = <String>[];
  final followed = <String>[];
  final unfollowed = <String>[];
  final blocked = <String>[];
  final unblocked = <String>[];

  void _throwIfNeeded() {
    final value = error;
    if (value != null) throw value;
  }

  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) async {
    statusCalls.add(userId);
    _throwIfNeeded();
    return relation.copyWith(targetUserId: userId);
  }

  @override
  Future<void> followUser(String userId) async {
    _throwIfNeeded();
    followed.add(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    _throwIfNeeded();
    unfollowed.add(userId);
  }

  @override
  Future<void> blockUser(String userId) async {
    _throwIfNeeded();
    blocked.add(userId);
  }

  @override
  Future<void> unblockUser(String userId) async {
    _throwIfNeeded();
    unblocked.add(userId);
  }

  @override
  Future<List<SocialUserEntity>> getUserFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async => const [];

  @override
  Future<List<SocialUserEntity>> getUserFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async => const [];

  @override
  Future<List<SocialUserEntity>> getMyFollowers({int page = 1, int limit = 20}) async => const [];

  @override
  Future<List<SocialUserEntity>> getMyFollowing({int page = 1, int limit = 20}) async => const [];

  @override
  Future<List<SocialUserEntity>> getBlockedUsers({int page = 1, int limit = 20}) async => const [];

  @override
  Future<List<SocialUserEntity>> getTrueFriends({int page = 1, int limit = 20}) async => const [];

  @override
  Future<List<SocialUserEntity>> getSuggestedUsers({int page = 1, int limit = 20}) async => const [];

  @override
  Future<List<SocialUserEntity>> getSuggestedArtists({int page = 1, int limit = 20}) async => const [];
}
