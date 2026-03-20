import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/update_upload_usecase.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockLibraryUploadsRepository mockRepository;
  late UpdateUploadUsecase usecase;

  setUp(() {
    mockRepository = MockLibraryUploadsRepository();
    usecase = UpdateUploadUsecase(mockRepository);
  });

  test('updates an upload and returns the updated item', () async {
    when(
      mockRepository.updateUpload(
        trackId: 'track-1',
        title: 'Updated Title',
        description: 'Updated Description',
        privacy: 'private',
        localArtworkPath: '/tmp/art.png',
      ),
    ).thenAnswer((_) async => sampleUploadItem);

    final result = await usecase(
      trackId: 'track-1',
      title: 'Updated Title',
      description: 'Updated Description',
      privacy: 'private',
      localArtworkPath: '/tmp/art.png',
    );

    expect(result, sampleUploadItem);
    verify(
      mockRepository.updateUpload(
        trackId: 'track-1',
        title: 'Updated Title',
        description: 'Updated Description',
        privacy: 'private',
        localArtworkPath: '/tmp/art.png',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
