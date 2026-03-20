import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/cloudinary_upload_repository_impl.dart';
import 'package:software_project/features/audio_upload_and_management/data/repository/cloudinary_upload_workflow.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/cloudinary_asset_delete_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/cloudinary_media_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/global_track_store.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/shared/upload_error_helpers.dart';

import '../../../helpers/upload_mocks.mocks.dart';
import '../helpers/upload_test_data.dart';

void main() {
  Response<Map<String, dynamic>> response(Map<String, dynamic> data) {
    return Response<Map<String, dynamic>>(
      data: data,
      requestOptions: RequestOptions(path: '/test'),
      statusCode: 200,
    );
  }

  void clearStore() {
    for (final item in GlobalTrackStore.instance.all.toList()) {
      GlobalTrackStore.instance.remove(item.id);
    }
  }

  setUp(clearStore);
  tearDown(clearStore);

  group('cloudinary asset helpers', () {
    test('extracts public ids from versioned cloudinary urls', () {
      expect(
        publicIdFromCloudinaryUrl(
          'https://res.cloudinary.com/demo/video/upload/v123/tracks/song.mp3',
          resourceType: 'video',
        ),
        'tracks/song',
      );
      expect(
        publicIdFromCloudinaryUrl(
          'https://res.cloudinary.com/demo/image/upload/covers/cover.png',
          resourceType: 'image',
        ),
        'covers/cover',
      );
      expect(publicIdFromCloudinaryUrl(null, resourceType: 'video'), isNull);
      expect(
        publicIdFromCloudinaryUrl(
          'https://res.cloudinary.com/demo/image/upload/covers/cover.png',
          resourceType: 'video',
        ),
        isNull,
      );
    });

    test('deleteCloudinaryAssetByUrl ignores missing ids and validates delete responses', () async {
      final mockDio = MockDio();
      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => response({'result': 'ok'}));

      await deleteCloudinaryAssetByUrl(
        dio: mockDio,
        cloudName: 'demo',
        apiKey: 'key',
        apiSecret: 'secret',
        assetUrl:
            'https://res.cloudinary.com/demo/video/upload/v123/tracks/song.mp3',
        resourceType: 'video',
      );

      verify(
        mockDio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/demo/video/destroy',
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).called(1);

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => response({'result': 'error'}));

      expect(
        deleteCloudinaryAssetByUrl(
          dio: mockDio,
          cloudName: 'demo',
          apiKey: 'key',
          apiSecret: 'secret',
          assetUrl:
              'https://res.cloudinary.com/demo/image/upload/v123/covers/cover.png',
          resourceType: 'image',
        ),
        throwsA(isA<UploadFlowException>()),
      );

      await deleteCloudinaryAssetByUrl(
        dio: mockDio,
        cloudName: 'demo',
        apiKey: 'key',
        apiSecret: 'secret',
        assetUrl: null,
        resourceType: 'image',
      );
    });
  });

  group('CloudinaryMediaService', () {
    late MockDio mockDio;
    late CloudinaryMediaService service;

    setUp(() {
      mockDio = MockDio();
      service = CloudinaryMediaService(
        dio: mockDio,
        cloudName: 'demo',
        audioUploadPreset: 'audio-preset',
        imageUploadPreset: 'image-preset',
        apiKey: 'key',
        apiSecret: 'secret',
      );
    });

    test('reports configuration and builds waveform urls', () {
      expect(service.isConfigured, isTrue);
      expect(service.canDeleteAssets, isTrue);
      expect(
        service.buildWaveformImageUrl(audioPublicId: 'tracks/song'),
        contains('fl_waveform'),
      );
    });

    test('throws when uploads are not configured', () {
      final unconfigured = CloudinaryMediaService(
        dio: mockDio,
        cloudName: '',
        audioUploadPreset: '',
        imageUploadPreset: '',
      );

      expect(
        unconfigured.uploadAudio(
          filePath: 'missing.mp3',
          fileName: 'missing.mp3',
          onSendProgress: (_, __) {},
        ),
        throwsA(isA<UploadFlowException>()),
      );
    });

    test('uploads audio and artwork and validates incomplete responses', () async {
      final directory = await Directory.systemTemp.createTemp('cloudinary_media');
      addTearDown(() => directory.delete(recursive: true));
      final audioFile = File('${directory.path}/song.mp3');
      final imageFile = File('${directory.path}/cover.png');
      await audioFile.writeAsString('audio');
      await imageFile.writeAsString('image');

      when(
        mockDio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/demo/video/upload',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => response({
          'secure_url': 'https://cdn.example.com/song.mp3',
          'public_id': 'tracks/song',
          'resource_type': 'video',
          'duration': 245.2,
          'bytes': 1048576,
          'format': 'mp3',
          'original_filename': 'song',
        }),
      );
      when(
        mockDio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/demo/image/upload',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => response({
          'secure_url': 'https://cdn.example.com/cover.png',
          'public_id': 'covers/cover',
          'resource_type': 'image',
        }),
      );

      final audio = await service.uploadAudio(
        filePath: audioFile.path,
        fileName: 'song.mp3',
        onSendProgress: (_, __) {},
      );
      final artwork = await service.uploadArtwork(
        filePath: imageFile.path,
        fileName: 'cover.png',
      );

      expect(audio.publicId, 'tracks/song');
      expect(audio.durationSeconds, 245);
      expect(artwork.secureUrl, 'https://cdn.example.com/cover.png');

      when(
        mockDio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/demo/image/upload',
          data: anyNamed('data'),
          cancelToken: anyNamed('cancelToken'),
          options: anyNamed('options'),
          onSendProgress: anyNamed('onSendProgress'),
        ),
      ).thenAnswer((_) async => response({'public_id': 'covers/cover'}));

      expect(
        service.uploadArtwork(filePath: imageFile.path, fileName: 'cover.png'),
        throwsA(isA<UploadFlowException>()),
      );
    });

    test('deleteTrackAssets calls cloudinary delete for audio and artwork urls', () async {
      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => response({'result': 'ok'}));

      await service.deleteTrackAssets(
        audioUrl:
            'https://res.cloudinary.com/demo/video/upload/v123/tracks/song.mp3',
        artworkUrl:
            'https://res.cloudinary.com/demo/image/upload/v123/covers/cover.png',
      );

      verify(
        mockDio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/demo/video/destroy',
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).called(1);
      verify(
        mockDio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/demo/image/destroy',
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).called(1);
    });
  });

  group('Cloudinary upload workflow and repository', () {
    late MockCloudinaryMediaService mockMediaService;
    late MockUploadWaveformService mockWaveformService;
    late CloudinaryUploadWorkflow workflow;

    setUp(() {
      mockMediaService = MockCloudinaryMediaService();
      mockWaveformService = MockUploadWaveformService();
      workflow = CloudinaryUploadWorkflow(mockMediaService, mockWaveformService);
    });

    test('createTrack creates drafts and finalizeMetadata requires uploaded audio', () async {
      final created = await workflow.createTrack('user-1');

      expect(created.status, UploadStatus.idle);
      expect(
        workflow.finalizeMetadata(
          trackId: created.trackId,
          metadata: sampleTrackMetadata,
        ),
        throwsA(isA<UploadFlowException>()),
      );
    });

    test('upload finalize process and get details save finished tracks to the global store', () async {
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
        mockMediaService.uploadArtwork(
          filePath: r'C:\art\cover.png',
          fileName: 'cover.png',
        ),
      ).thenAnswer(
        (_) async => const CloudinaryAsset(
          secureUrl: 'https://cdn.example.com/cover.png',
          publicId: 'covers/cover',
          resourceType: 'image',
        ),
      );
      when(
        mockWaveformService.generateDisplayBarsFromFile(
          samplePickedUploadFile.path,
        ),
      ).thenAnswer((_) async => const [0.2, 0.8]);

      final created = await workflow.createTrack('user-1');
      final uploaded = await workflow.uploadAudio(
        trackId: created.trackId,
        file: samplePickedUploadFile,
        onProgress: (_) {},
      );
      final finalized = await workflow.finalizeMetadata(
        trackId: created.trackId,
        metadata: TrackMetadata(
          title: sampleTrackMetadata.title,
          genreCategory: sampleTrackMetadata.genreCategory,
          genreSubGenre: sampleTrackMetadata.genreSubGenre,
          tags: sampleTrackMetadata.tags,
          description: sampleTrackMetadata.description,
          privacy: sampleTrackMetadata.privacy,
          artists: sampleTrackMetadata.artists,
          artworkPath: r'C:\art\cover.png',
          recordLabel: sampleTrackMetadata.recordLabel,
          publisher: sampleTrackMetadata.publisher,
          isrc: sampleTrackMetadata.isrc,
          pLine: sampleTrackMetadata.pLine,
          contentWarning: sampleTrackMetadata.contentWarning,
          scheduledReleaseDate: sampleTrackMetadata.scheduledReleaseDate,
          allowDownloads: sampleTrackMetadata.allowDownloads,
          offlineListening: sampleTrackMetadata.offlineListening,
          includeInRss: sampleTrackMetadata.includeInRss,
          displayEmbedCode: sampleTrackMetadata.displayEmbedCode,
          appPlaybackEnabled: sampleTrackMetadata.appPlaybackEnabled,
          availabilityType: sampleTrackMetadata.availabilityType,
          availabilityRegions: sampleTrackMetadata.availabilityRegions,
          licensing: sampleTrackMetadata.licensing,
        ),
      );
      final finished = await workflow.waitUntilProcessed(created.trackId);
      final details = await workflow.getTrackDetails(created.trackId);

      expect(uploaded.status, UploadStatus.processing);
      expect(finalized.status, UploadStatus.processing);
      expect(finished.status, UploadStatus.finished);
      expect(details.title, 'Midnight Echo');
      expect(GlobalTrackStore.instance.find(created.trackId)?.waveformBars, [0.2, 0.8]);
    });

    test('updateTrackMetadata rebuilds from stored uploads and deleteTrack wraps asset failures', () async {
      GlobalTrackStore.instance.add(sampleUploadItem);
      when(
        mockWaveformService.generateDisplayBarsFromFile(sampleUploadItem.audioUrl!),
      ).thenAnswer((_) async => null);
      when(
        mockMediaService.deleteTrackAssets(
          audioUrl: sampleUploadItem.audioUrl,
          artworkUrl: sampleUploadItem.artworkUrl,
        ),
      ).thenThrow(Exception('boom'));

      final updated = await workflow.updateTrackMetadata(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );

      expect(updated.status, UploadStatus.finished);
      expect(GlobalTrackStore.instance.find('track-1')?.title, 'Midnight Echo');

      expect(
        workflow.deleteTrack('track-1'),
        throwsA(isA<UploadFlowException>()),
      );
    });

    test('deleteTrack removes stored tracks when cloud deletion succeeds and repository delegates through workflow', () async {
      GlobalTrackStore.instance.add(sampleUploadItem);
      when(
        mockMediaService.deleteTrackAssets(
          audioUrl: sampleUploadItem.audioUrl,
          artworkUrl: sampleUploadItem.artworkUrl,
        ),
      ).thenAnswer((_) async {});

      await workflow.deleteTrack('track-1');
      expect(GlobalTrackStore.instance.find('track-1'), isNull);

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

      final created = await repository.createTrack('user-1');
      final quota = await repository.getUploadQuota('user-1');
      final uploaded = await repository.uploadAudio(
        trackId: created.trackId,
        file: samplePickedUploadFile,
        onProgress: (_) {},
      );

      expect(quota.uploadMinutesRemaining, 172);
      expect(uploaded.status, UploadStatus.processing);
    });
  });
}
