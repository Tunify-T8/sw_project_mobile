import 'dart:async';
import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../domain/repositories/upload_repository.dart';
import '../api/upload_api.dart';
import '../dto/create_track_request_dto.dart';
import '../dto/finalize_track_metadata_request_dto.dart';
import '../mappers/upload_mappers.dart';

class RealUploadRepository implements UploadRepository {
  final UploadApi api;

  RealUploadRepository(this.api);

  @override
  Future<UploadQuota> getUploadQuota(String userId) async {
    final dto = await api.getUploadQuota(userId);
    return dto.toEntity();
  }

  @override
  Future<UploadedTrack> createTrack(String userId) async {
    final dto = await api.createTrack(CreateTrackRequestDto(userId: userId));
    return dto.toEntity();
  }

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
  }) async {
    final dto = await api.uploadAudio(
      trackId: trackId,
      filePath: file.path,
      fileName: file.name,
      onSendProgress: (sent, total) {
        if (total > 0) {
          onProgress(sent / total);
        }
      },
    );

    return dto.toEntity();
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final request = FinalizeTrackMetadataRequestDto.fromEntity(
      trackId: trackId,
      metadata: metadata,
    );

    final dto = await api.finalizeMetadata(request);
    return dto.toEntity();
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    const maxAttempts = 30;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final dto = await api.getTrackStatus(trackId);
      final track = dto.toEntity();

      if (track.status == UploadStatus.finished ||
          track.status == UploadStatus.failed) {
        return track;
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    throw Exception('Processing timeout: track did not finish in time.');
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    final dto = await api.getTrackDetails(trackId);
    return dto.toEntity();
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final request = FinalizeTrackMetadataRequestDto.fromEntity(
      trackId: trackId,
      metadata: metadata,
    );

    final dto = await api.updateTrackMetadata(request);
    return dto.toEntity();
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await api.deleteTrack(trackId);
  }
}
