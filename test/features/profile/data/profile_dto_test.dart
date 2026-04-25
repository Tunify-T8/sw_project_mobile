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
        visibility: 'PUBLIC',
        userType: 'ARTIST',
      );

      expect(dto.userName, 'Darine');
      expect(dto.bio, 'Music lover');
      expect(dto.city, 'Cairo');
      expect(dto.country, 'Egypt');
      expect(dto.visibility, 'PUBLIC');
      expect(dto.userType, 'ARTIST');
    });

    test('has correct default values', () {
      final dto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
        visibility: 'PUBLIC',
        userType: 'ARTIST',
      );

      expect(dto.id, '');
      expect(dto.email, isNull);
      expect(dto.role, 'USER');
      expect(dto.followersCount, isNull);
      expect(dto.followingCount, isNull);
      expect(dto.tracksCount, isNull);
      expect(dto.likesReceived, isNull);
      expect(dto.isActive, isNull);
      expect(dto.isCertified, isNull);
      expect(dto.displayName, isNull);
      expect(dto.instagram, isNull);
      expect(dto.twitter, isNull);
      expect(dto.profileImagePath, isNull);
      expect(dto.coverImagePath, isNull);
    });

    test('accepts all optional fields', () {
      final dto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
        visibility: 'PUBLIC',
        userType: 'LISTENER',
        id: '1',
        email: 'darine@email.com',
        role: 'ADMIN',
        displayName: 'Darine M',
        instagram: 'https://instagram.com/darine',
        twitter: 'https://twitter.com/darine',
        youtube: 'https://youtube.com/darine',
        spotify: 'https://spotify.com/darine',
        tiktok: 'https://tiktok.com/darine',
        soundcloud: 'https://soundcloud.com/darine',
        followersCount: 300,
        followingCount: 1,
        tracksCount: 5,
        likesReceived: 10,
        isCertified: true,
        isActive: false,
        profileImagePath: 'https://image.url/photo.jpg',
        coverImagePath: 'https://image.url/cover.jpg',
      );

      expect(dto.id, '1');
      expect(dto.email, 'darine@email.com');
      expect(dto.role, 'ADMIN');
      expect(dto.displayName, 'Darine M');
      expect(dto.instagram, 'https://instagram.com/darine');
      expect(dto.twitter, 'https://twitter.com/darine');
      expect(dto.youtube, 'https://youtube.com/darine');
      expect(dto.spotify, 'https://spotify.com/darine');
      expect(dto.tiktok, 'https://tiktok.com/darine');
      expect(dto.soundcloud, 'https://soundcloud.com/darine');
      expect(dto.followersCount, 300);
      expect(dto.followingCount, 1);
      expect(dto.tracksCount, 5);
      expect(dto.likesReceived, 10);
      expect(dto.isCertified, true);
      expect(dto.isActive, false);
      expect(dto.userType, 'LISTENER');
      expect(dto.profileImagePath, 'https://image.url/photo.jpg');
      expect(dto.coverImagePath, 'https://image.url/cover.jpg');
    });
  });
}