import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/profile/data/dto/profile_dto.dart';

void main() {
  group('ProfileDto', () {
    test('creates with required fields', () {
      final dto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
      );

      expect(dto.userName, 'Darine');
      expect(dto.bio, 'Music lover');
      expect(dto.city, 'Cairo');
      expect(dto.country, 'Egypt');
    });

    test('has correct default values', () {
      final dto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
      );

      expect(dto.followersCount, 0);
      expect(dto.followingCount, 0);
      expect(dto.visibility, 'PUBLIC');
      expect(dto.userType, 'ARTIST');
      expect(dto.instagram, null);
      expect(dto.twitter, null);
      expect(dto.website, null);
      expect(dto.profileImagePath, null);
      expect(dto.coverImagePath, null);
    });

    test('accepts optional fields', () {
      final dto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
        instagram: 'https://instagram.com/darine',
        twitter: 'https://twitter.com/darine',
        website: 'https://darine.com',
        followersCount: 300,
        followingCount: 1,
        userType: 'LISTENER',
      );

      expect(dto.instagram, 'https://instagram.com/darine');
      expect(dto.followersCount, 300);
      expect(dto.userType, 'LISTENER');
    });
  });
}