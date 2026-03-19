import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/artist_tools_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/track_response_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_item_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/mappers/library_uploads_mapper.dart';
import 'package:software_project/features/audio_upload_and_management/data/mappers/upload_mappers.dart';
import 'package:software_project/features/audio_upload_and_management/data/mappers/upload_status_mapper.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/artist_tools_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';

import '../../helpers/upload_test_data.dart';

void main() {
  group('UploadQuotaDtoMapper', () {
    test('maps upload quota dto to entity', () {
      final dto = UploadQuotaDto.fromJson(sampleUploadQuotaJson());

      final entity = dto.toEntity();

      expect(entity.tier, 'free');
      expect(entity.uploadMinutesRemaining, 168);
      expect(entity.canUpgrade, isFalse);
    });
  });

  group('TrackResponseDtoMapper', () {
    test('maps track response dto to uploaded track entity', () {
      final dto = TrackResponseDto.fromJson(sampleTrackResponseJson(status: 'finished'));

      final entity = dto.toEntity();

      expect(entity.trackId, 'track-1');
      expect(entity.status, UploadStatus.finished);
      expect(entity.audioUrl, contains('track-1.mp3'));
    });
  });

  group('UploadItemDtoMapper', () {
    test('maps upload item dto to upload item entity', () {
      final dto = UploadItemDto.fromJson(sampleUploadItemJson(status: 'processing'));

      final entity = dto.toEntity();

      expect(entity.id, 'track-1');
      expect(entity.status.name, 'processing');
      expect(entity.visibility.name, 'public');
      expect(entity.waveformBars, [0.2, 0.4, 0.6]);
    });
  });

  group('ArtistToolsQuotaDtoMapper', () {
    test('maps free tier and upgrade flags', () {
      const dto = ArtistToolsQuotaDto(
        tier: 'free',
        uploadMinutesLimit: 180,
        uploadMinutesUsed: 12,
        canReplaceFiles: false,
        canUpgrade: true,
      );

      final entity = dto.toEntity();

      expect(entity.tier, ArtistTier.free);
      expect(entity.canUpgrade, isTrue);
      expect(entity.uploadMinutesRemaining, 168);
    });
  });

  group('UploadStatusMapper', () {
    test('maps known values and falls back to idle', () {
      expect(UploadStatusMapper.fromString('idle'), UploadStatus.idle);
      expect(UploadStatusMapper.fromString('uploading'), UploadStatus.uploading);
      expect(UploadStatusMapper.fromString('processing'), UploadStatus.processing);
      expect(UploadStatusMapper.fromString('finished'), UploadStatus.finished);
      expect(UploadStatusMapper.fromString('failed'), UploadStatus.failed);
      expect(UploadStatusMapper.fromString('unknown'), UploadStatus.idle);
    });
  });
}
