import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/delete_upload_usecase.dart';

import '../../../helpers/upload_mocks.mocks.dart';

void main() {
  late MockLibraryUploadsRepository mockRepository;
  late DeleteUploadUsecase usecase;

  setUp(() {
    mockRepository = MockLibraryUploadsRepository();
    usecase = DeleteUploadUsecase(mockRepository);
  });

  test('deletes the requested track', () async {
    when(mockRepository.deleteUpload('track-1')).thenAnswer((_) async {});

    await usecase('track-1');

    verify(mockRepository.deleteUpload('track-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
