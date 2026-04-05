import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/auth/domain/entities/auth_user_entity.dart';
import 'package:software_project/features/profile/data/api/profile_api.dart';
import 'package:software_project/features/profile/data/dto/profile_dto.dart';
import 'package:software_project/features/profile/data/repository/profile_repository_impl.dart';

import '../../../helpers/mocks.mocks.dart';

class MockProfileApi extends Mock implements ProfileApi {
  @override
  Future<ProfileDto> getProfile(String userId) =>
      super.noSuchMethod(
        Invocation.method(#getProfile, [userId]),
        returnValue: Future.value(_fakeDto()),
      ) as Future<ProfileDto>;

  @override
  Future<ProfileDto> getProfileById(String userIdOrUsername) =>
      super.noSuchMethod(
        Invocation.method(#getProfileById, [userIdOrUsername]),
        returnValue: Future.value(_fakeDto()),
      ) as Future<ProfileDto>;

  @override
  Future<ProfileDto> updateProfile(String userId, ProfileDto profile) =>
      super.noSuchMethod(
        Invocation.method(#updateProfile, [userId, profile]),
        returnValue: Future.value(profile),
      ) as Future<ProfileDto>;
}

ProfileDto _fakeDto({
  String id = 'user-1',
  String userName = 'Artist One',
  String bio = '',
  String city = '',
  String country = '',
}) =>
    ProfileDto(
      id: id,
      email: 'artist@test.com',
      role: 'ARTIST',
      userName: userName,
      bio: bio,
      city: city,
      country: country,
      userType: 'ARTIST',
      tracksCount: 3,
      followersCount: 10,
      followingCount: 5,
      likesReceived: 20,
      isActive: true,
      isCertified: false,
    );

void main() {
  late MockTokenStorage mockTokenStorage;
  late MockProfileApi mockProfileApi;
  late ProfileRepositoryImpl repository;

  const user = AuthUserEntity(
    id: 'user-1',
    email: 'artist@test.com',
    username: 'Artist One',
    role: 'ARTIST',
    isVerified: true,
  );

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    mockProfileApi = MockProfileApi();
    repository = ProfileRepositoryImpl(
      tokenStorage: mockTokenStorage,
      profileApi: mockProfileApi,
    );
    when(mockTokenStorage.getUser()).thenAnswer((_) async => user);
  });

  group('constructor', () {
    test('uses default ProfileApi and GlobalTrackStore when not provided', () {
      final repo = ProfileRepositoryImpl(
        tokenStorage: mockTokenStorage,
      );
      expect(repo, isNotNull);
    });
  });

  group('getProfile', () {
    test('calls api with authenticated user id', () async {
      final dto = _fakeDto(id: user.id, userName: user.username);
      when(mockProfileApi.getProfile(user.id)).thenAnswer((_) async => dto);

      final result = await repository.getProfile();

      verify(mockProfileApi.getProfile(user.id)).called(1);
      expect(result.userName, user.username);
      expect(result.id, user.id);
    });

    test('throws when no authenticated user', () async {
      when(mockTokenStorage.getUser()).thenAnswer((_) async => null);

      expect(() => repository.getProfile(), throwsException);
    });
  });

  group('getProfileById', () {
    test('calls api with given user id', () async {
      const otherId = 'other-user-123';
      final dto = _fakeDto(id: otherId, userName: 'Other User');
      when(mockProfileApi.getProfileById(otherId))
          .thenAnswer((_) async => dto);

      final result = await repository.getProfileById(otherId);

      verify(mockProfileApi.getProfileById(otherId)).called(1);
      expect(result.id, otherId);
      expect(result.userName, 'Other User');
    });

    test('calls api with username string', () async {
      const username = 'someartist';
      final dto = _fakeDto(userName: username);
      when(mockProfileApi.getProfileById(username))
          .thenAnswer((_) async => dto);

      await repository.getProfileById(username);

      verify(mockProfileApi.getProfileById(username)).called(1);
    });
  });

  group('updateProfile', () {
    test('calls api with authenticated user id and given profile', () async {
      final updated = _fakeDto(
        id: user.id,
        userName: 'Updated Name',
        bio: 'New bio',
        city: 'Cairo',
        country: 'Egypt',
      );
      when(mockProfileApi.updateProfile(user.id, updated))
          .thenAnswer((_) async => updated);

      final result = await repository.updateProfile(updated);

      verify(mockProfileApi.updateProfile(user.id, updated)).called(1);
      expect(result.userName, 'Updated Name');
      expect(result.bio, 'New bio');
      expect(result.city, 'Cairo');
      expect(result.country, 'Egypt');
    });

    test('throws when no authenticated user', () async {
      when(mockTokenStorage.getUser()).thenAnswer((_) async => null);

      expect(
        () => repository.updateProfile(_fakeDto()),
        throwsException,
      );
    });
  });
}
