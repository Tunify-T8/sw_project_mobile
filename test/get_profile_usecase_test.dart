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
        website: 'https://darine.com',
        followersCount: 300,
        followingCount: 1,
        profileImagePath: 'https://image.url/photo.jpg',
        coverImagePath: 'https://image.url/cover.jpg',
        userType: 'ARTIST',
        visibility: 'PUBLIC',
      );

      when(mockRepository.getProfile()).thenAnswer((_) async => fullDto);

      final result = await usecase.execute();

      expect(result.instagram, 'https://instagram.com/darine');
      expect(result.profileImagePath, 'https://image.url/photo.jpg');
      expect(result.visibility, 'PUBLIC');
    });

    test('throws exception when repository fails', () async {
      when(mockRepository.getProfile()).thenThrow(Exception('Network error'));

      expect(() => usecase.execute(), throwsException);
    });
  });
}
