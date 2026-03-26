import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../shared/upload_error_helpers.dart';
import '../../domain/entities/upload_cancellation_token.dart';
import '../dto/create_track_request_dto.dart';
import '../dto/finalize_track_metadata_request_dto.dart';
import '../dto/track_response_dto.dart';
import '../dto/upload_quota_dto.dart';

class UploadApi {
  final Dio dio;

  UploadApi(this.dio);

  // ---------------------------------------------------------------------------
  // 4.1  GET /users/:userId/artist-tools/upload-minutes — upload quota
  // ---------------------------------------------------------------------------
  // ⚠️  Backend bug: subscription.uploadedMinutes is never incremented after
  // a track processes, so the API always returns uploadMinutesUsed: 0.
  // We fetch the user's tracks in parallel and compute used minutes ourselves
  // as sum(durationSeconds / 60) for all finished tracks.
  Future<UploadQuotaDto> getUploadQuota(String userId) async {
    // Fetch quota and tracks in parallel
    final results = await Future.wait([
      dio.get(ApiEndpoints.artistToolsQuota(userId)),
      dio.get(ApiEndpoints.myUploads).catchError((_) => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.myUploads),
            data: <dynamic>[],
            statusCode: 200,
          )),
    ]);

    final quotaResponse = results[0] as Response;
    final tracksResponse = results[1] as Response;

    final raw = quotaResponse.data;
    final map = raw is Map<String, dynamic>
        ? (raw['data'] is Map<String, dynamic>
            ? raw['data'] as Map<String, dynamic>
            : raw)
        : <String, dynamic>{};

    // Compute real used minutes from finished tracks
    final trackList = tracksResponse.data;
    final tracks = trackList is List ? trackList : <dynamic>[];
    final computedUsedSeconds = tracks
        .whereType<Map<String, dynamic>>()
        .where((t) => t['status'] == 'finished')
        .fold<int>(
          0,
          (sum, t) =>
              sum + ((t['duration'] ?? t['durationSeconds'] ?? 0) as num).toInt(),
        );
    final computedUsedMinutes = (computedUsedSeconds / 60).ceil();
    final limit = (map['uploadMinutesLimit'] as num?)?.toInt() ?? 99;

    final correctedMap = Map<String, dynamic>.from(map)
      ..['uploadMinutesUsed'] = computedUsedMinutes
      ..['uploadMinutesRemaining'] =
          (limit - computedUsedMinutes).clamp(0, limit);

    return UploadQuotaDto.fromJson(correctedMap);
  }

  Future<TrackResponseDto> createTrack(CreateTrackRequestDto request) async {
    final response = await dio.post(
      ApiEndpoints.createTrack(),
      data: request.toJson(),
    );
    // Backend returns the raw Prisma track object on POST /tracks.
    // It uses `id` not `trackId`, and `transcodingStatus` not `status`.
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> uploadAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
    UploadCancellationToken? cancellationToken,
  }) async {
    final cancelToken = CancelToken();
    cancellationToken?.addListener(() {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Upload cancelled by user.');
      }
    });

    // Backend controller uses FileInterceptor('file') — field must be 'file'.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      ApiEndpoints.uploadAudio(trackId),
      data: formData,
      cancelToken: cancelToken,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    // uploadAudio returns { message: '...' } — not a full track object.
    // Synthesize a minimal DTO so the rest of the flow keeps working.
    return TrackResponseDto(
      trackId: trackId,
      status: 'uploading',
    );
  }

  Future<TrackResponseDto> replaceAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
  }) async {
    // Backend controller uses FileInterceptor('file') — field must be 'file'.
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dio.post(
      ApiEndpoints.replaceAudio(trackId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );

    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  // finalizeMetadata — two-step:
  //   1. PATCH JSON (metadata with real booleans — no @Transform issues)
  //   2. PATCH multipart (artwork only) if a local file was picked
  Future<TrackResponseDto> finalizeMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    // Step 1 — metadata as JSON
    final response = await dio.patch(
      ApiEndpoints.finalizeMetadata(request.trackId),
      data: request.toJsonBody(),
      options: Options(contentType: 'application/json'),
    );
    final result = TrackResponseDto.fromJson(_normalizeTrackJson(response.data));

    // Step 2 — artwork as separate multipart PATCH (best-effort)
    if (request.hasLocalArtwork) {
      try {
        await dio.patch(
          ApiEndpoints.finalizeMetadata(request.trackId),
          data: FormData.fromMap({
            'artwork': await MultipartFile.fromFile(request.artworkPath!),
          }),
          options: Options(contentType: 'multipart/form-data'),
        );
      } catch (_) {
        // Artwork upload failed — metadata was already saved, keep going.
      }
    }

    return result;
  }

  Future<TrackResponseDto> getTrackStatus(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackStatus(trackId));
    // GET :id/status returns { id, transcodingStatus, durationSeconds,
    // audioUrl, waveformUrl } — normalise to our standard shape.
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  Future<TrackResponseDto> getTrackDetails(String trackId) async {
    final response = await dio.get(ApiEndpoints.trackDetails(trackId));
    // GET :id wraps in { track: {...}, statusCode: 200 }
    return TrackResponseDto.fromJson(_normalizeTrackJson(response.data));
  }

  // updateTrackMetadata — same two-step approach.
  Future<TrackResponseDto> updateTrackMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) async {
    final response = await dio.patch(
      ApiEndpoints.updateTrack(request.trackId),
      data: request.toJsonBody(),
      options: Options(contentType: 'application/json'),
    );
    final result = TrackResponseDto.fromJson(_normalizeTrackJson(response.data));

    if (request.hasLocalArtwork) {
      try {
        await dio.patch(
          ApiEndpoints.updateTrack(request.trackId),
          data: FormData.fromMap({
            'artwork': await MultipartFile.fromFile(request.artworkPath!),
          }),
          options: Options(contentType: 'multipart/form-data'),
        );
      } catch (_) {}
    }

    return result;
  }

  Future<void> deleteTrack(String trackId) async {
    await dio.delete(ApiEndpoints.deleteTrack(trackId));
  }

  // ---------------------------------------------------------------------------
  // Response normalisation
  // ---------------------------------------------------------------------------

  /// Unwraps every response shape the backend produces and returns a flat map
  /// with the canonical keys `trackId` and `status` that TrackResponseDto
  /// expects.
  ///
  /// Known shapes:
  ///   • POST /tracks          → raw Prisma object: { id, transcodingStatus, … }
  ///   • POST :id/audio        → { message: '…' }   (handled before this)
  ///   • GET  :id/status       → { id, transcodingStatus, audioUrl, … }
  ///   • GET  :id              → { track: { trackId, status, … }, statusCode }
  ///   • PATCH :id             → { trackId, status, … }
  ///   • POST :id/audio/replace→ { trackId, status, … }
  Map<String, dynamic> _normalizeTrackJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const UploadFlowException(
        'The server returned an unexpected upload response.',
      );
    }

    Map<String, dynamic> map = raw;

    // Unwrap { track: {...}, statusCode: 200 } envelope (GET :id)
    if (map.containsKey('track') && map['track'] is Map<String, dynamic>) {
      map = map['track'] as Map<String, dynamic>;
    }

    // Unwrap { data: {...} } envelope (future-proofing)
    if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    // Normalise `id` → `trackId`
    if (!map.containsKey('trackId') && map.containsKey('id')) {
      map = Map<String, dynamic>.from(map);
      (map as Map<String, dynamic>)['trackId'] = map['id'];
    }

    // Normalise `transcodingStatus` → `status`
    if (!map.containsKey('status') && map.containsKey('transcodingStatus')) {
      map = Map<String, dynamic>.from(map);
      (map as Map<String, dynamic>)['status'] = map['transcodingStatus'];
    }

    return map;
  }
}