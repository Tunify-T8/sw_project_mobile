import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/dto/social_relation_dto.dart';
import 'package:software_project/features/followers_and_social_graph/data/mappers/social_relation_mapper.dart';

void main() {
  group('SocialRelationDtoMapper.toEntity', () {
    final dto = SocialRelationDTO(
      isFollowing: true,
      isBlocked: true,
    );

    test('maps all relation fields correctly', () {
      final entity = dto.toEntity('target-user-1');

      expect(entity.isFollowing, dto.isFollowing);
      expect(entity.isBlocked, dto.isBlocked);
    });

    test('targetUserId is injected correctly', () {
      final entity = dto.toEntity('target-user-77');

      expect(entity.targetUserId, 'target-user-77');
    });
  });
}
