import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/messaging_track_sharing/data/dto/user_preview_dto.dart';

void main() {
  group('UserPreviewDto', () {
    test('prefers username over backend placeholder display name', () {
      final dto = UserPreviewDto.fromJson({
        'id': 'user-1',
        'displayName': 'Unknown display name',
        'username': 'Joe',
        'avatarUrl': null,
      });

      expect(dto.id, 'user-1');
      expect(dto.displayName, 'Joe');
      expect(dto.avatarUrl, isNull);
    });

    test('falls back to display name when username is missing', () {
      final dto = UserPreviewDto.fromJson({
        'id': 'user-2',
        'displayName': 'Rozana Ahmed',
      });

      expect(dto.displayName, 'Rozana Ahmed');
    });
  });
}
