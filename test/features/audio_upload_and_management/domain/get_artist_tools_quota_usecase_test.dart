import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_artist_tools_quota_usecase.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockLibraryUploadsRepository mockRepository;
  late GetArtistToolsQuotaUsecase usecase;

  setUp(() {
    mockRepository = MockLibraryUploadsRepository();
    usecase = GetArtistToolsQuotaUsecase(mockRepository);
  });

  test('returns artist tools quota from the repository', () async {
    when(
      mockRepository.getArtistToolsQuota(),
    ).thenAnswer((_) async => sampleArtistToolsQuota);

    final result = await usecase();

    expect(result.tier, sampleArtistToolsQuota.tier);
    expect(result.uploadMinutesLimit, sampleArtistToolsQuota.uploadMinutesLimit);
    expect(result.uploadMinutesUsed, sampleArtistToolsQuota.uploadMinutesUsed);
    expect(
      result.uploadMinutesRemaining,
      sampleArtistToolsQuota.uploadMinutesRemaining,
    );
    expect(result.canUpgrade, sampleArtistToolsQuota.canUpgrade);
    verify(mockRepository.getArtistToolsQuota()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
