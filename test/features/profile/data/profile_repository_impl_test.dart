import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/profile/data/dto/profile_dto.dart';
import 'package:software_project/features/profile/data/repository/profile_repository_impl.dart';

import '../../../helpers/mocks.mocks.dart';

void main() {
  UploadItem buildItem({required String id, required String title}) {
    return UploadItem(
      id: id,
      title: title,
      artistDisplay: 'Artist',
      durationLabel: '1:00',
      durationSeconds: 60,
      artworkUrl: null,
      visibility: UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  setUp(() {
    GlobalTrackStore.instance.clear();
  });

  tearDown(() {
    GlobalTrackStore.instance.clear();
  });

  test(
    'getProfile uses the authenticated user and only their uploads',
    () async {
      final mockTokenStorage = MockTokenStorage();
      const user = AuthUserEntity(
        id: 'artist-1',
        email: 'artist@test.com',
        username: 'Artist One',
        role: 'ARTIST',
        isVerified: true,
        avatarUrl: 'https://cdn.example.com/artist.png',
      );

      when(mockTokenStorage.getUser()).thenAnswer((_) async => user);

      GlobalTrackStore.instance.add(
        buildItem(id: 'track-1', title: 'Mine'),
        ownerUserId: user.id,
      );
      GlobalTrackStore.instance.add(
        buildItem(id: 'track-2', title: 'Another User Track'),
        ownerUserId: 'artist-2',
      );

      final repository = ProfileRepositoryImpl(
        tokenStorage: mockTokenStorage,
        trackStore: GlobalTrackStore.instance,
      );
      final profile = await repository.getProfile();

      expect(profile.userName, user.username);
      expect(profile.email, user.email);
      expect(profile.profileImagePath, user.avatarUrl);
      expect(profile.tracksCount, 1);
      expect(profile.userType, 'ARTIST');
    },
  );

  test('updateProfile persists editable fields for the current user', () async {
    final mockTokenStorage = MockTokenStorage();
    const user = AuthUserEntity(
      id: 'artist-3',
      email: 'artist3@test.com',
      username: 'Artist Three',
      role: 'ARTIST',
      isVerified: true,
    );

    when(mockTokenStorage.getUser()).thenAnswer((_) async => user);

    final repository = ProfileRepositoryImpl(
      tokenStorage: mockTokenStorage,
      trackStore: GlobalTrackStore.instance,
    );

    await repository.updateProfile(
      ProfileDto(
        userName: 'Updated Artist',
        bio: 'Producer and vocalist',
        city: 'Cairo',
        country: 'Egypt',
        instagram: 'https://instagram.com/updatedartist',
        visibility: 'PUBLIC',
        userType: 'ARTIST',
      ),
    );

    final profile = await repository.getProfile();

    expect(profile.userName, 'Artist Three');
    expect(profile.bio, 'Producer and vocalist');
    expect(profile.city, 'Cairo');
    expect(profile.country, 'Egypt');
    expect(profile.instagram, 'https://instagram.com/updatedartist');
  });
}
