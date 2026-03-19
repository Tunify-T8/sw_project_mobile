import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/replace_file_usecase.dart';

import '../../../helpers/upload_mocks.mocks.dart';

void main() {
  late MockLibraryUploadsRepository mockRepository;
  late ReplaceFileUsecase usecase;

  setUp(() {
    mockRepository = MockLibraryUploadsRepository();
    usecase = ReplaceFileUsecase(mockRepository);
  });

  test('replaces the file through the repository', () async {
    when(
      mockRepository.replaceUploadFile(
        trackId: 'track-1',
        filePath: '/tmp/replacement.mp3',
      ),
    ).thenAnswer((_) async {});

    await usecase(trackId: 'track-1', filePath: '/tmp/replacement.mp3');

    verify(
      mockRepository.replaceUploadFile(
        trackId: 'track-1',
        filePath: '/tmp/replacement.mp3',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
