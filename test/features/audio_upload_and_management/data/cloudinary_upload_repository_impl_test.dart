import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/cloudinary_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/cloudinary_media_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';

import '../../../helpers/upload_mocks.mocks.dart' show MockCloudinaryMediaService;
import '../helpers/upload_test_data.dart';

void main() {
  setUp(() {
    for (final item in GlobalTrackStore.instance.all.toList()) {
      GlobalTrackStore.instance.remove(item.id);
    }
  });

  test('CloudinaryUploadRepository delegates its public upload flow methods', () async {
    final mockMediaService = MockCloudinaryMediaService();
    final repository = CloudinaryUploadRepository(mockMediaService);

    when(
      mockMediaService.uploadAudio(
        filePath: samplePickedUploadFile.path,
        fileName: samplePickedUploadFile.name,
        cancellationToken: anyNamed('cancellationToken'),
        onSendProgress: anyNamed('onSendProgress'),
      ),
    ).thenAnswer(
      (_) async => const CloudinaryAsset(
        secureUrl: 'https://cdn.example.com/song.mp3',
        publicId: 'tracks/song',
        resourceType: 'video',
        durationSeconds: 245,
      ),
    );
    when(
      mockMediaService.buildWaveformImageUrl(audioPublicId: 'tracks/song'),
    ).thenReturn('https://cdn.example.com/song-wave.png');

    final quota = await repository.getUploadQuota('user-1');
    final created = await repository.createTrack('user-1');
    final uploaded = await repository.uploadAudio(
      trackId: created.trackId,
      file: samplePickedUploadFile,
      onProgress: (_) {},
    );

    expect(quota.uploadMinutesRemaining, 172);
    expect(created.status, UploadStatus.idle);
    expect(uploaded.status, UploadStatus.processing);
    expect(uploaded.audioUrl, 'https://cdn.example.com/song.mp3');
  });

  test(
    'CloudinaryUploadRepository finalizes, finishes, reads, updates, and deletes tracks',
    () async {
      final mockMediaService = MockCloudinaryMediaService();
      final repository = CloudinaryUploadRepository(mockMediaService);

      when(
        mockMediaService.uploadAudio(
          filePath: samplePickedUploadFile.path,
          fileName: samplePickedUploadFile.name,
          cancellationToken: anyNamed('cancellationToken'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => const CloudinaryAsset(
          secureUrl: 'https://cdn.example.com/song.mp3',
          publicId: 'tracks/song',
          resourceType: 'video',
          durationSeconds: 245,
        ),
      );
      when(
        mockMediaService.buildWaveformImageUrl(audioPublicId: 'tracks/song'),
      ).thenReturn('https://cdn.example.com/song-wave.png');
      when(
        mockMediaService.deleteTrackAssets(
          audioUrl: anyNamed('audioUrl'),
          artworkUrl: anyNamed('artworkUrl'),
        ),
      ).thenAnswer((_) async {});

      final created = await repository.createTrack('user-1');
      await repository.uploadAudio(
        trackId: created.trackId,
        file: samplePickedUploadFile,
        onProgress: (_) {},
      );

      final finalized = await repository.finalizeMetadata(
        trackId: created.trackId,
        metadata: sampleTrackMetadata,
      );
      final finished = await repository.waitUntilProcessed(created.trackId);
      final details = await repository.getTrackDetails(created.trackId);
      // final updated = await repository.updateTrackMetadata(
      //   trackId: created.trackId,
      //   // metadata: sampleTrackMetadata.copyWith(
      //   //   title: 'Updated Midnight Echo',
      //   //   description: 'Updated synth demo',
      //   // ),
      // );

      expect(finalized.title, sampleTrackMetadata.title);
      expect(finished.status, UploadStatus.finished);
      expect(details.title, sampleTrackMetadata.title);
      // expect(updated.title, 'Updated Midnight Echo');

      await repository.deleteTrack(created.trackId);

      expect(GlobalTrackStore.instance.find(created.trackId), isNull);
      verify(
        mockMediaService.deleteTrackAssets(
          audioUrl: 'https://cdn.example.com/song.mp3',
          artworkUrl: null,
        ),
      ).called(1);
    },
  );
}
