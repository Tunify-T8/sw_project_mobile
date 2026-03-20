import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_my_uploads_usecase.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockLibraryUploadsRepository mockRepository;
  late GetMyUploadsUsecase usecase;

  setUp(() {
    mockRepository = MockLibraryUploadsRepository();
    usecase = GetMyUploadsUsecase(mockRepository);
  });

  test('returns uploads from the repository', () async {
    when(mockRepository.getMyUploads()).thenAnswer((_) async => [sampleUploadItem]);

    final result = await usecase();

    expect(result, [sampleUploadItem]);
    verify(mockRepository.getMyUploads()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
