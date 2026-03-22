import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/profile/domain/repositories/profile_repository.dart';
import 'package:software_project/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:software_project/features/profile/data/dto/profile_dto.dart';

import 'get_profile_usecase_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetProfileUsecase usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetProfileUsecase(mockRepository);
  });

  group('GetProfileUsecase', () {
    final mockDto = ProfileDto(
      userName: 'Darine',
      bio: 'Music lover',
      city: 'Cairo',
      country: 'Egypt',
      followersCount: 300,
      followingCount: 1,
      visibility: 'PUBLIC',
      userType: 'ARTIST',
    );

    test('returns ProfileEntity from repository', () async {
      when(mockRepository.getProfile()).thenAnswer((_) async => mockDto);

      final result = await usecase.execute();

      expect(result.userName, 'Darine');
      expect(result.city, 'Cairo');
      expect(result.followersCount, 300);
      expect(result.userType, 'ARTIST');
    });

    test('maps all DTO fields to entity correctly', () async {
      final fullDto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
        instagram: 'https://instagram.com/darine',
        twitter: 'https://twitter.com/darine',
        followersCount: 300,
        followingCount: 1,
        profileImagePath: 'https://image.url/photo.jpg',
        coverImagePath: 'https://image.url/cover.jpg',
        visibility: 'PUBLIC',
        userType: 'ARTIST',
      );

      when(mockRepository.getProfile()).thenAnswer((_) async => fullDto);

      final result = await usecase.execute();

      expect(result.instagram, 'https://instagram.com/darine');
      expect(result.profileImagePath, 'https://image.url/photo.jpg');
      expect(result.visibility, 'PUBLIC');
    });

    test('maps new DTO fields to entity correctly', () async {
      final dto = ProfileDto(
        userName: 'Darine',
        bio: 'Music lover',
        city: 'Cairo',
        country: 'Egypt',
        visibility: 'PUBLIC',
        userType: 'ARTIST',
        tracksCount: 5,
        isVerified: true,
        email: 'darine@email.com',
        role: 'USER',
      );

      when(mockRepository.getProfile()).thenAnswer((_) async => dto);
      final result = await usecase.execute();

      expect(result.tracksCount, 5);
      expect(result.isVerified, true);
      expect(result.email, 'darine@email.com');
      expect(result.role, 'USER');
    });

    test('throws exception when repository fails', () async {
      when(mockRepository.getProfile()).thenThrow(Exception('Network error'));

      expect(() => usecase.execute(), throwsException);
    });
  });
}
