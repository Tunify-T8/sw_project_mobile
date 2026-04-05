import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/audio_upload_and_management/data/api/library_uploads_api.dart'
    as real_library_api;
import 'package:software_project/features/audio_upload_and_management/data/api/mock_library_uploads_api.dart'
    as mock_library_api;
import 'package:software_project/features/audio_upload_and_management/data/api/upload_api.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/artist_tools_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/create_track_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/finalize_track_metadata_request_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/track_response_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_item_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/dto/upload_quota_dto.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/file_picker_service.dart';
import 'package:software_project/features/audio_upload_and_management/data/services/mock_upload_service.dart'
    as mock_upload_service;
import 'package:software_project/features/audio_upload_and_management/domain/entities/artist_tools_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/picked_upload_file.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_cancellation_token.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/library_uploads_repository.dart';
import 'package:software_project/features/audio_upload_and_management/domain/repositories/upload_repository.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/delete_upload_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_artist_tools_quota_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/get_my_uploads_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/replace_file_usecase.dart';
import 'package:software_project/features/audio_upload_and_management/domain/usecases/update_upload_usecase.dart';

Response<T> _emptyResponse<T>(String path) => Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
    );

UploadQuota _dummyUploadQuota() => const UploadQuota(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 0,
      uploadMinutesRemaining: 180,
      canReplaceFiles: false,
      canScheduleRelease: false,
      canAccessAdvancedTab: false,
    );

ArtistToolsQuota _dummyArtistToolsQuota() => const ArtistToolsQuota(
      tier: ArtistTier.free,
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 0,
      canReplaceFiles: false,
      canUpgrade: true,
    );

UploadedTrack _dummyUploadedTrack() => const UploadedTrack(
      trackId: 'track-1',
      status: UploadStatus.idle,
    );

UploadItem _dummyUploadItem() => UploadItem(
      id: 'track-1',
      title: 'Track',
      artistDisplay: 'Artist',
      durationLabel: '0:00',
      durationSeconds: 0,
      artworkUrl: '',
      visibility: UploadVisibility.private,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );

UploadItemDto _dummyUploadItemDto() => UploadItemDto(
      id: 'track-1',
      title: 'Track',
      artists: const ['Artist'],
      durationSeconds: 0,
      artworkUrl: '',
      privacy: 'private',
      status: 'finished',
      contentWarning: false,
      createdAt: DateTime.utc(2026, 1, 1).toIso8601String(),
    );

class MockDio extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#get, [path], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future<Response<T>>.value(_emptyResponse<T>(path)),
      returnValueForMissingStub:
          Future<Response<T>>.value(_emptyResponse<T>(path)),
    ) as Future<Response<T>>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#post, [path], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onSendProgress: onSendProgress,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future<Response<T>>.value(_emptyResponse<T>(path)),
      returnValueForMissingStub:
          Future<Response<T>>.value(_emptyResponse<T>(path)),
    ) as Future<Response<T>>;
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#patch, [path], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
        #onSendProgress: onSendProgress,
        #onReceiveProgress: onReceiveProgress,
      }),
      returnValue: Future<Response<T>>.value(_emptyResponse<T>(path)),
      returnValueForMissingStub:
          Future<Response<T>>.value(_emptyResponse<T>(path)),
    ) as Future<Response<T>>;
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return super.noSuchMethod(
      Invocation.method(#delete, [path], {
        #data: data,
        #queryParameters: queryParameters,
        #options: options,
        #cancelToken: cancelToken,
      }),
      returnValue: Future<Response<T>>.value(_emptyResponse<T>(path)),
      returnValueForMissingStub:
          Future<Response<T>>.value(_emptyResponse<T>(path)),
    ) as Future<Response<T>>;
  }
}

class MockUploadApi extends Mock implements UploadApi {
  @override
  Future<UploadQuotaDto> getUploadQuota(String userId) {
    return super.noSuchMethod(
      Invocation.method(#getUploadQuota, [userId]),
      returnValue: Future.value(
        UploadQuotaDto.fromJson(const {
          'tier': 'free',
          'uploadMinutesLimit': 180,
          'uploadMinutesUsed': 0,
          'uploadMinutesRemaining': 180,
          'canReplaceFiles': false,
          'canScheduleRelease': false,
          'canAccessAdvancedTab': false,
        }),
      ),
      returnValueForMissingStub: Future.value(
        UploadQuotaDto.fromJson(const {
          'tier': 'free',
          'uploadMinutesLimit': 180,
          'uploadMinutesUsed': 0,
          'uploadMinutesRemaining': 180,
          'canReplaceFiles': false,
          'canScheduleRelease': false,
          'canAccessAdvancedTab': false,
        }),
      ),
    ) as Future<UploadQuotaDto>;
  }

  @override
  Future<TrackResponseDto> createTrack(CreateTrackRequestDto request) {
    return super.noSuchMethod(
      Invocation.method(#createTrack, [request]),
      returnValue: Future.value(
        TrackResponseDto(trackId: 'track-1', status: 'idle'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: 'track-1', status: 'idle'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<TrackResponseDto> uploadAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
    UploadCancellationToken? cancellationToken,
  }) {
    return super.noSuchMethod(
      Invocation.method(#uploadAudio, [], {
        #trackId: trackId,
        #filePath: filePath,
        #fileName: fileName,
        #onSendProgress: onSendProgress,
        #cancellationToken: cancellationToken,
      }),
      returnValue: Future.value(
        TrackResponseDto(trackId: trackId, status: 'uploading'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: trackId, status: 'uploading'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<TrackResponseDto> replaceAudio({
    required String trackId,
    required String filePath,
    required String fileName,
    required ProgressCallback onSendProgress,
  }) {
    return super.noSuchMethod(
      Invocation.method(#replaceAudio, [], {
        #trackId: trackId,
        #filePath: filePath,
        #fileName: fileName,
        #onSendProgress: onSendProgress,
      }),
      returnValue: Future.value(
        TrackResponseDto(trackId: trackId, status: 'processing'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: trackId, status: 'processing'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<TrackResponseDto> finalizeMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) {
    return super.noSuchMethod(
      Invocation.method(#finalizeMetadata, [request]),
      returnValue: Future.value(
        TrackResponseDto(trackId: request.trackId, status: 'processing'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: request.trackId, status: 'processing'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<TrackResponseDto> getTrackStatus(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#getTrackStatus, [trackId]),
      returnValue: Future.value(
        TrackResponseDto(trackId: trackId, status: 'finished'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: trackId, status: 'finished'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<TrackResponseDto> getTrackDetails(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#getTrackDetails, [trackId]),
      returnValue: Future.value(
        TrackResponseDto(trackId: trackId, status: 'finished'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: trackId, status: 'finished'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<TrackResponseDto> updateTrackMetadata(
    FinalizeTrackMetadataRequestDto request,
  ) {
    return super.noSuchMethod(
      Invocation.method(#updateTrackMetadata, [request]),
      returnValue: Future.value(
        TrackResponseDto(trackId: request.trackId, status: 'finished'),
      ),
      returnValueForMissingStub: Future.value(
        TrackResponseDto(trackId: request.trackId, status: 'finished'),
      ),
    ) as Future<TrackResponseDto>;
  }

  @override
  Future<void> deleteTrack(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#deleteTrack, [trackId]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }
}

class MockLibraryUploadsApi extends Mock
    implements real_library_api.LibraryUploadsApi {
  @override
  Future<List<UploadItemDto>> getMyUploads() {
    return super.noSuchMethod(
      Invocation.method(#getMyUploads, []),
      returnValue: Future.value([_dummyUploadItemDto()]),
      returnValueForMissingStub: Future.value([_dummyUploadItemDto()]),
    ) as Future<List<UploadItemDto>>;
  }

  @override
  Future<ArtistToolsQuotaDto> getArtistToolsQuota() {
    return super.noSuchMethod(
      Invocation.method(#getArtistToolsQuota, []),
      returnValue: Future.value(const ArtistToolsQuotaDto(
        tier: 'free',
        uploadMinutesLimit: 180,
        uploadMinutesUsed: 0,
        canReplaceFiles: false,
        canUpgrade: true,
      )),
      returnValueForMissingStub: Future.value(const ArtistToolsQuotaDto(
        tier: 'free',
        uploadMinutesLimit: 180,
        uploadMinutesUsed: 0,
        canReplaceFiles: false,
        canUpgrade: true,
      )),
    ) as Future<ArtistToolsQuotaDto>;
  }

  @override
  Future<void> deleteUpload(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#deleteUpload, [trackId]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#replaceUploadFile, [], {
        #trackId: trackId,
        #filePath: filePath,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<UploadItemDto> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#updateUpload, [], {
        #trackId: trackId,
        #title: title,
        #description: description,
        #privacy: privacy,
        #localArtworkPath: localArtworkPath,
      }),
      returnValue: Future.value(_dummyUploadItemDto()),
      returnValueForMissingStub: Future.value(_dummyUploadItemDto()),
    ) as Future<UploadItemDto>;
  }
}

class MockMockLibraryUploadsApi extends Mock
    implements mock_library_api.MockLibraryUploadsApi {
  @override
  Future<List<UploadItemDto>> getMyUploads() {
    return super.noSuchMethod(
      Invocation.method(#getMyUploads, []),
      returnValue: Future.value([_dummyUploadItemDto()]),
      returnValueForMissingStub: Future.value([_dummyUploadItemDto()]),
    ) as Future<List<UploadItemDto>>;
  }

  @override
  Future<ArtistToolsQuotaDto> getArtistToolsQuota() {
    return super.noSuchMethod(
      Invocation.method(#getArtistToolsQuota, []),
      returnValue: Future.value(const ArtistToolsQuotaDto(
        tier: 'free',
        uploadMinutesLimit: 180,
        uploadMinutesUsed: 0,
        canReplaceFiles: false,
        canUpgrade: true,
      )),
      returnValueForMissingStub: Future.value(const ArtistToolsQuotaDto(
        tier: 'free',
        uploadMinutesLimit: 180,
        uploadMinutesUsed: 0,
        canReplaceFiles: false,
        canUpgrade: true,
      )),
    ) as Future<ArtistToolsQuotaDto>;
  }

  @override
  Future<void> deleteUpload(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#deleteUpload, [trackId]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#replaceUploadFile, [], {
        #trackId: trackId,
        #filePath: filePath,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<UploadItemDto> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#updateUpload, [], {
        #trackId: trackId,
        #title: title,
        #description: description,
        #privacy: privacy,
        #localArtworkPath: localArtworkPath,
      }),
      returnValue: Future.value(_dummyUploadItemDto()),
      returnValueForMissingStub: Future.value(_dummyUploadItemDto()),
    ) as Future<UploadItemDto>;
  }
}

class MockUploadRepository extends Mock implements UploadRepository {
  @override
  Future<UploadQuota> getUploadQuota(String userId) {
    return super.noSuchMethod(
      Invocation.method(#getUploadQuota, [userId]),
      returnValue: Future.value(_dummyUploadQuota()),
      returnValueForMissingStub: Future.value(_dummyUploadQuota()),
    ) as Future<UploadQuota>;
  }

  @override
  Future<UploadedTrack> createTrack(String userId) {
    return super.noSuchMethod(
      Invocation.method(#createTrack, [userId]),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
    UploadCancellationToken? cancellationToken,
  }) {
    return super.noSuchMethod(
      Invocation.method(#uploadAudio, [], {
        #trackId: trackId,
        #file: file,
        #onProgress: onProgress,
        #cancellationToken: cancellationToken,
      }),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return super.noSuchMethod(
      Invocation.method(#finalizeMetadata, [], {
        #trackId: trackId,
        #metadata: metadata,
      }),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#waitUntilProcessed, [trackId]),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<UploadedTrack> getTrackStatus(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#getTrackStatus, [trackId]),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#getTrackDetails, [trackId]),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) {
    return super.noSuchMethod(
      Invocation.method(#updateTrackMetadata, [], {
        #trackId: trackId,
        #metadata: metadata,
      }),
      returnValue: Future.value(_dummyUploadedTrack()),
      returnValueForMissingStub: Future.value(_dummyUploadedTrack()),
    ) as Future<UploadedTrack>;
  }

  @override
  Future<void> deleteTrack(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#deleteTrack, [trackId]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }
}

class MockLibraryUploadsRepository extends Mock
    implements LibraryUploadsRepository {
  @override
  Future<List<UploadItem>> getMyUploads() {
    return super.noSuchMethod(
      Invocation.method(#getMyUploads, []),
      returnValue: Future.value([_dummyUploadItem()]),
      returnValueForMissingStub: Future.value([_dummyUploadItem()]),
    ) as Future<List<UploadItem>>;
  }

  @override
  Future<ArtistToolsQuota> getArtistToolsQuota() {
    return super.noSuchMethod(
      Invocation.method(#getArtistToolsQuota, []),
      returnValue: Future.value(_dummyArtistToolsQuota()),
      returnValueForMissingStub: Future.value(_dummyArtistToolsQuota()),
    ) as Future<ArtistToolsQuota>;
  }

  @override
  Future<void> deleteUpload(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#deleteUpload, [trackId]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<void> replaceUploadFile({
    required String trackId,
    required String filePath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#replaceUploadFile, [], {
        #trackId: trackId,
        #filePath: filePath,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<UploadItem> updateUpload({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#updateUpload, [], {
        #trackId: trackId,
        #title: title,
        #description: description,
        #privacy: privacy,
        #localArtworkPath: localArtworkPath,
      }),
      returnValue: Future.value(_dummyUploadItem()),
      returnValueForMissingStub: Future.value(_dummyUploadItem()),
    ) as Future<UploadItem>;
  }
}

class MockFilePickerService extends Mock implements FilePickerService {
  @override
  Future<PickedUploadFile?> pickAudioFile() {
    return super.noSuchMethod(
      Invocation.method(#pickAudioFile, []),
      returnValue: Future<PickedUploadFile?>.value(null),
      returnValueForMissingStub: Future<PickedUploadFile?>.value(null),
    ) as Future<PickedUploadFile?>;
  }

  @override
  Future<String?> pickArtworkImage({bool fromCamera = false}) {
    return super.noSuchMethod(
      Invocation.method(#pickArtworkImage, [], {
        #fromCamera: fromCamera,
      }),
      returnValue: Future<String?>.value(null),
      returnValueForMissingStub: Future<String?>.value(null),
    ) as Future<String?>;
  }
}

class MockMockUploadService extends Mock
    implements mock_upload_service.MockUploadService {
  @override
  Future<Map<String, dynamic>> getUploadQuota({required String userId}) {
    return super.noSuchMethod(
      Invocation.method(#getUploadQuota, [], {#userId: userId}),
      returnValue: Future.value({
        'tier': 'free',
        'uploadMinutesLimit': 180,
        'uploadMinutesUsed': 0,
        'uploadMinutesRemaining': 180,
        'canReplaceFiles': false,
        'canScheduleRelease': false,
        'canAccessAdvancedTab': false,
      }),
      returnValueForMissingStub: Future.value({
        'tier': 'free',
        'uploadMinutesLimit': 180,
        'uploadMinutesUsed': 0,
        'uploadMinutesRemaining': 180,
        'canReplaceFiles': false,
        'canScheduleRelease': false,
        'canAccessAdvancedTab': false,
      }),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Future<Map<String, dynamic>> createTrack({required String userId}) {
    return super.noSuchMethod(
      Invocation.method(#createTrack, [], {#userId: userId}),
      returnValue: Future.value({'trackId': 'track-1', 'status': 'idle'}),
      returnValueForMissingStub:
          Future.value({'trackId': 'track-1', 'status': 'idle'}),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Stream<double> uploadProgress() {
    return super.noSuchMethod(
      Invocation.method(#uploadProgress, []),
      returnValue: const Stream<double>.empty(),
      returnValueForMissingStub: const Stream<double>.empty(),
    ) as Stream<double>;
  }

  @override
  Future<Map<String, dynamic>> uploadAudio({
    required String trackId,
    String? localFilePath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#uploadAudio, [], {
        #trackId: trackId,
        #localFilePath: localFilePath,
      }),
      returnValue: Future.value({'trackId': trackId, 'status': 'uploading'}),
      returnValueForMissingStub:
          Future.value({'trackId': trackId, 'status': 'uploading'}),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Future<Map<String, dynamic>> replaceAudio({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#replaceAudio, [], {#trackId: trackId}),
      returnValue: Future.value({'trackId': trackId, 'status': 'processing'}),
      returnValueForMissingStub:
          Future.value({'trackId': trackId, 'status': 'processing'}),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Future<Map<String, dynamic>> finalizeMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) {
    return super.noSuchMethod(
      Invocation.method(#finalizeMetadata, [], {
        #trackId: trackId,
        #metadata: metadata,
      }),
      returnValue: Future.value({'trackId': trackId, 'status': 'processing'}),
      returnValueForMissingStub:
          Future.value({'trackId': trackId, 'status': 'processing'}),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Future<Map<String, dynamic>> pollTrackStatus({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#pollTrackStatus, [], {#trackId: trackId}),
      returnValue: Future.value({'trackId': trackId, 'status': 'finished'}),
      returnValueForMissingStub:
          Future.value({'trackId': trackId, 'status': 'finished'}),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Future<Map<String, dynamic>> getTrackDetails({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#getTrackDetails, [], {#trackId: trackId}),
      returnValue: Future.value({'trackId': trackId, 'status': 'finished'}),
      returnValueForMissingStub:
          Future.value({'trackId': trackId, 'status': 'finished'}),
    ) as Future<Map<String, dynamic>>;
  }

  @override
  Future<void> deleteTrack({required String trackId}) {
    return super.noSuchMethod(
      Invocation.method(#deleteTrack, [], {#trackId: trackId}),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Future<Map<String, dynamic>> updateTrackMetadata({
    required String trackId,
    required Map<String, dynamic> metadata,
  }) {
    return super.noSuchMethod(
      Invocation.method(#updateTrackMetadata, [], {
        #trackId: trackId,
        #metadata: metadata,
      }),
      returnValue: Future.value({'trackId': trackId, 'status': 'finished'}),
      returnValueForMissingStub:
          Future.value({'trackId': trackId, 'status': 'finished'}),
    ) as Future<Map<String, dynamic>>;
  }
}

class MockGetMyUploadsUsecase extends Mock implements GetMyUploadsUsecase {
  @override
  Future<List<UploadItem>> call() {
    return super.noSuchMethod(
      Invocation.method(#call, []),
      returnValue: Future.value([_dummyUploadItem()]),
      returnValueForMissingStub: Future.value([_dummyUploadItem()]),
    ) as Future<List<UploadItem>>;
  }
}

class MockGetArtistToolsQuotaUsecase extends Mock
    implements GetArtistToolsQuotaUsecase {
  @override
  Future<ArtistToolsQuota> call() {
    return super.noSuchMethod(
      Invocation.method(#call, []),
      returnValue: Future.value(_dummyArtistToolsQuota()),
      returnValueForMissingStub: Future.value(_dummyArtistToolsQuota()),
    ) as Future<ArtistToolsQuota>;
  }
}

class MockDeleteUploadUsecase extends Mock implements DeleteUploadUsecase {
  @override
  Future<void> call(String trackId) {
    return super.noSuchMethod(
      Invocation.method(#call, [trackId]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }
}

class MockReplaceFileUsecase extends Mock implements ReplaceFileUsecase {
  @override
  Future<void> call({required String trackId, required String filePath}) {
    return super.noSuchMethod(
      Invocation.method(#call, [], {
        #trackId: trackId,
        #filePath: filePath,
      }),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }
}

class MockUpdateUploadUsecase extends Mock implements UpdateUploadUsecase {
  @override
  Future<UploadItem> call({
    required String trackId,
    required String title,
    required String description,
    required String privacy,
    String? localArtworkPath,
  }) {
    return super.noSuchMethod(
      Invocation.method(#call, [], {
        #trackId: trackId,
        #title: title,
        #description: description,
        #privacy: privacy,
        #localArtworkPath: localArtworkPath,
      }),
      returnValue: Future.value(_dummyUploadItem()),
      returnValueForMissingStub: Future.value(_dummyUploadItem()),
    ) as Future<UploadItem>;
  }
}