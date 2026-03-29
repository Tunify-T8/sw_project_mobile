import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/upload_track_metadata_usecase.dart';

import '../helpers/local_upload_test_mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockUploadRepository mockRepository;
  late UploadTrackMetadataUsecase usecase;

  setUp(() {
    mockRepository = MockUploadRepository();
    usecase = UploadTrackMetadataUsecase(mockRepository);
  });

  test('finalizes metadata for the uploaded track', () async {
    when(
      mockRepository.finalizeMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      ),
    ).thenAnswer((_) async => sampleUploadedTrack);

    final result = await usecase(
      trackId: 'track-1',
      metadata: sampleTrackMetadata,
    );

    expect(result.trackId, sampleUploadedTrack.trackId);
    expect(result.status, sampleUploadedTrack.status);
    expect(result.audioUrl, sampleUploadedTrack.audioUrl);
    verify(
      mockRepository.finalizeMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
