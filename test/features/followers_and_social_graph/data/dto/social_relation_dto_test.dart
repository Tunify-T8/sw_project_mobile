import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/followers_and_social_graph/data/dto/social_relation_dto.dart';

void main() {
  group('SocialRelationDTO.fromJson', () {
    test('maps all booleans correctly', () {
      final dto = SocialRelationDTO.fromJson({
        'isFollowing': true,
        'isFollowedBy': false,
        'isMutual': true,
        'isBlocked': true,
      });

      expect(dto.isFollowing, isTrue);
      expect(dto.isFollowedBy, isFalse);
      expect(dto.isMutual, isTrue);
      expect(dto.isBlocked, isTrue);
    });

    test('defaults all booleans to false when keys are absent', () {
      final dto = SocialRelationDTO.fromJson({});

      expect(dto.isFollowing, isFalse);
      expect(dto.isFollowedBy, isFalse);
      expect(dto.isMutual, isFalse);
      expect(dto.isBlocked, isFalse);
    });
  });
}
