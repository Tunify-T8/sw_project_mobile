import 'package:mockito/mockito.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_user_entity.dart';
import 'package:software_project/features/followers_and_social_graph/domain/repositories/social_graph_repository.dart';

class MockSocialGraphRepository extends Mock implements SocialGraphRepository {
  @override
  Future<void> blockUser(String userId) => super.noSuchMethod(
        Invocation.method(#blockUser, [userId]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> followUser(String userId) => super.noSuchMethod(
        Invocation.method(#followUser, [userId]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<List<SocialUserEntity>> getBlockedUsers({
    int page = 1,
    int limit = 20,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getBlockedUsers, const [], {
          #page: page,
          #limit: limit,
        }),
        returnValue: Future<List<SocialUserEntity>>.value(const []),
        returnValueForMissingStub:
            Future<List<SocialUserEntity>>.value(const []),
      ) as Future<List<SocialUserEntity>>;

  @override
  Future<List<SocialUserEntity>> getFollowers({
    required String userId,
    int page = 1,
    int limit = 20,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getFollowers, const [], {
          #userId: userId,
          #page: page,
          #limit: limit,
        }),
        returnValue: Future<List<SocialUserEntity>>.value(const []),
        returnValueForMissingStub:
            Future<List<SocialUserEntity>>.value(const []),
      ) as Future<List<SocialUserEntity>>;

  @override
  Future<SocialRelationEntity> getFollowStatus(String userId) =>
      super.noSuchMethod(
        Invocation.method(#getFollowStatus, [userId]),
        returnValue: Future<SocialRelationEntity>.value(
          const SocialRelationEntity(
            targetUserId: '',
            isFollowing: false,
            isFollowedBy: false,
            isMutual: false,
          ),
        ),
        returnValueForMissingStub: Future<SocialRelationEntity>.value(
          const SocialRelationEntity(
            targetUserId: '',
            isFollowing: false,
            isFollowedBy: false,
            isMutual: false,
          ),
        ),
      ) as Future<SocialRelationEntity>;

  @override
  Future<List<SocialUserEntity>> getFollowing({
    required String userId,
    int page = 1,
    int limit = 20,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getFollowing, const [], {
          #userId: userId,
          #page: page,
          #limit: limit,
        }),
        returnValue: Future<List<SocialUserEntity>>.value(const []),
        returnValueForMissingStub:
            Future<List<SocialUserEntity>>.value(const []),
      ) as Future<List<SocialUserEntity>>;

  @override
  Future<List<SocialUserEntity>> getMutualFriends({
    required String userId,
    int page = 1,
    int limit = 20,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getMutualFriends, const [], {
          #userId: userId,
          #page: page,
          #limit: limit,
        }),
        returnValue: Future<List<SocialUserEntity>>.value(const []),
        returnValueForMissingStub:
            Future<List<SocialUserEntity>>.value(const []),
      ) as Future<List<SocialUserEntity>>;

  @override
  Future<List<SocialUserEntity>> getSuggestedUsers({
    int page = 1,
    int limit = 20,
    String? genre,
  }) =>
      super.noSuchMethod(
        Invocation.method(#getSuggestedUsers, const [], {
          #page: page,
          #limit: limit,
          #genre: genre,
        }),
        returnValue: Future<List<SocialUserEntity>>.value(const []),
        returnValueForMissingStub:
            Future<List<SocialUserEntity>>.value(const []),
      ) as Future<List<SocialUserEntity>>;

  @override
  Future<void> unblockUser(String userId) => super.noSuchMethod(
        Invocation.method(#unblockUser, [userId]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> unfollowUser(String userId) => super.noSuchMethod(
        Invocation.method(#unfollowUser, [userId]),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as Future<void>;
}
