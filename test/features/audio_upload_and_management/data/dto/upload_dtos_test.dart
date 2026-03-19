import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/create_track_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/finalize_track_metadata_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/track_response_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_item_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_quota_dto.dart';

import '../../helpers/upload_test_data.dart';

void main() {
  group('CreateTrackRequestDto', () {
    test('serializes to the expected JSON payload', () {
      final dto = CreateTrackRequestDto(
        userId: 'user-1',
        title: 'Midnight Echo',
        genre: 'music_hiphop',
        tags: const ['night', 'beats'],
        description: 'Synth demo',
        privacy: 'public',
        artists: const ['Kevin'],
        availabilityType: 'worldwide',
        availabilityRegions: const [],
        licensingType: 'creative_commons',
        allowAttribution: true,
        nonCommercial: true,
        noDerivatives: false,
        shareAlike: true,
        contentWarning: false,
        scheduledReleaseDate: '2026-04-01T00:00:00.000Z',
      );

      expect(dto.toJson(), {
        'title': 'Midnight Echo',
        'genre': 'music_hiphop',
        'tags': ['night', 'beats'],
        'description': 'Synth demo',
        'privacy': 'public',
        'artists': ['Kevin'],
        'availability': {
          'type': 'worldwide',
          'regions': <String>[],
        },
        'licensing': {
          'type': 'creative_commons',
          'allowAttribution': true,
          'nonCommercial': true,
          'noDerivatives': false,
          'shareAlike': true,
        },
        'scheduledReleaseDate': '2026-04-01T00:00:00.000Z',
        'contentWarning': false,
      });
    });
  });

  group('FinalizeTrackMetadataRequestDto', () {
    test('maps entity values and builds form data without artwork', () async {
      final dto = FinalizeTrackMetadataRequestDto.fromEntity(
        trackId: 'track-1',
        metadata: sampleTrackMetadata,
      );
      final formData = await dto.toFormData();

      expect(dto.genre, 'music_hiphop');
      expect(
        formData.fields.any(
          (entry) => entry.key == 'trackId' && entry.value == 'track-1',
        ),
        isTrue,
      );
      expect(
        formData.fields.any(
          (entry) => entry.key == 'title' && entry.value == 'Midnight Echo',
        ),
        isTrue,
      );
      expect(
        formData.fields.any(
          (entry) =>
              entry.key == 'permissions[includeInRSS]' &&
              entry.value == 'true',
        ),
        isTrue,
      );
      expect(
        formData.fields.any(
          (entry) =>
              entry.key == 'licensing[type]' &&
              entry.value == 'creative_commons',
        ),
        isTrue,
      );
      expect(formData.files, isEmpty);
    });

    test('attaches artwork file when artworkPath points to a local file', () async {
      final directory = await Directory.systemTemp.createTemp('upload_dto_test');
      addTearDown(() => directory.delete(recursive: true));
      final artwork = File('${directory.path}/cover.png');
      await artwork.writeAsString('image');

      final dto = FinalizeTrackMetadataRequestDto.fromEntity(
        trackId: 'track-1',
        metadata: TrackMetadata(
          title: sampleTrackMetadata.title,
          genreCategory: sampleTrackMetadata.genreCategory,
          genreSubGenre: sampleTrackMetadata.genreSubGenre,
          tags: sampleTrackMetadata.tags,
          description: sampleTrackMetadata.description,
          privacy: sampleTrackMetadata.privacy,
          artists: sampleTrackMetadata.artists,
          artworkPath: artwork.path,
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

      final formData = await dto.toFormData();

      expect(formData.files.single.key, 'artwork');
    });
  });

  group('TrackResponseDto', () {
    test('parses nested track fields and error details', () {
      final dto = TrackResponseDto.fromJson(
        sampleTrackResponseJson(
          status: 'failed',
          error: const {
            'code': 'TRANSCODING_FAILED',
            'message': 'Audio processing failed.',
          },
        ),
      );

      expect(dto.trackId, 'track-1');
      expect(dto.status, 'failed');
      expect(dto.availability?.type, 'worldwide');
      expect(dto.licensing?.allowAttribution, isTrue);
      expect(dto.permissions?.includeInRSS, isTrue);
      expect(dto.audioMetadata?.format, 'mp3');
      expect(dto.errorCode, 'TRANSCODING_FAILED');
      expect(dto.errorMessage, 'Audio processing failed.');
    });
  });

  group('UploadItemDto', () {
    test('parses from json, serializes back, and supports copyWith', () {
      final dto = UploadItemDto.fromJson(sampleUploadItemJson());
      final updated = dto.copyWith(title: 'Updated Title', privacy: 'private');

      expect(dto.waveformBars, [0.2, 0.4, 0.6]);
      expect(updated.title, 'Updated Title');
      expect(updated.privacy, 'private');
      expect(updated.toJson()['title'], 'Updated Title');
      expect(updated.toJson()['waveformBars'], [0.2, 0.4, 0.6]);
    });
  });

  group('UploadQuotaDto', () {
    test('parses upload quota values and canUpgrade getter', () {
      final dto = UploadQuotaDto.fromJson(sampleUploadQuotaJson());

      expect(dto.tier, 'free');
      expect(dto.uploadMinutesRemaining, 168);
      expect(dto.canUpgrade, isFalse);
    });
  });
}
