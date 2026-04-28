import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/domain/entities/social_relation_entity.dart';

void main() {
  group('SocialRelationEntity', () {
    test('constructor keeps provided values', () {
      const entity = SocialRelationEntity(
        targetUserId: 'user-1',
        isFollowing: true,
        isBlocked: true,
      );

      expect(entity.targetUserId, 'user-1');
      expect(entity.isFollowing, isTrue);
      expect(entity.isBlocked, isTrue);
    });

    test('copyWith updates only one field and preserves others', () {
      const entity = SocialRelationEntity(
        targetUserId: 'user-1',
        isFollowing: false,
        isBlocked: false,
      );

      final updated = entity.copyWith(isFollowing: true);

      expect(updated.targetUserId, entity.targetUserId);
      expect(updated.isFollowing, isTrue);
      expect(updated.isBlocked, entity.isBlocked);
    });

    test('copyWith updates all fields', () {
      const entity = SocialRelationEntity(
        targetUserId: 'user-1',
        isFollowing: false,
        isBlocked: false,
      );

      final updated = entity.copyWith(
        targetUserId: 'user-2',
        isFollowing: true,
        isBlocked: true,
      );

      expect(updated.targetUserId, 'user-2');
      expect(updated.isFollowing, isTrue);
      expect(updated.isBlocked, isTrue);
    });

    test('copyWith keeps original values when null parameters are passed', () {
      const entity = SocialRelationEntity(
        targetUserId: 'user-1',
        isFollowing: true,
        isBlocked: true,
      );

      final updated = entity.copyWith(
        targetUserId: null,
        isFollowing: null,
        isBlocked: null,
      );

      expect(updated.targetUserId, entity.targetUserId);
      expect(updated.isFollowing, entity.isFollowing);
      expect(updated.isBlocked, entity.isBlocked);
    });

    test('default isBlocked is false', () {
      const entity = SocialRelationEntity(
        targetUserId: 'user-1',
        isFollowing: false,
      );

      expect(entity.isBlocked, isFalse);
    });
  });
}
