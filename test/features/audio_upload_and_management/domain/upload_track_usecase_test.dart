import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/upload_track_usecase.dart';

import '../helpers/local_upload_test_mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  late MockUploadRepository mockRepository;
  late UploadTrackUsecase usecase;

  setUp(() {
    mockRepository = MockUploadRepository();
    usecase = UploadTrackUsecase(mockRepository);
  });

  test('creates a draft track then uploads the audio file', () async {
    const createdTrack = UploadedTrack(
      trackId: 'track-1',
      status: UploadStatus.idle,
    );

    final progressValues = <double>[];

    when(mockRepository.createTrack('user-1'))
        .thenAnswer((_) async => createdTrack);

    when(
      mockRepository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: progressValues.add,
        cancellationToken: null,
      ),
    ).thenAnswer((_) async {
      progressValues.add(1);
      return sampleUploadedTrack;
    });

    final result = await usecase(
      userId: 'user-1',
      file: samplePickedUploadFile,
      onProgress: progressValues.add,
    );

    expect(result.trackId, sampleUploadedTrack.trackId);
    expect(result.status, sampleUploadedTrack.status);
    expect(result.audioUrl, sampleUploadedTrack.audioUrl);
    expect(progressValues, [1]);

    verify(mockRepository.createTrack('user-1')).called(1);
    verify(
      mockRepository.uploadAudio(
        trackId: 'track-1',
        file: samplePickedUploadFile,
        onProgress: progressValues.add,
        cancellationToken: null,
      ),
    ).called(1);
  });
}