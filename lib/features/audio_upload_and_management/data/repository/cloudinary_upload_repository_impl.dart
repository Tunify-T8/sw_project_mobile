import '../../domain/entities/picked_upload_file.dart';
import '../../domain/entities/track_metadata.dart';
import '../../domain/entities/upload_item.dart';
import '../../domain/entities/upload_quota.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/entities/uploaded_track.dart';
import '../../domain/repositories/upload_repository.dart';
import '../services/cloudinary_media_service.dart';
import '../services/global_track_store.dart';

class CloudinaryUploadRepository implements UploadRepository {
  CloudinaryUploadRepository(this._mediaService);

  final CloudinaryMediaService _mediaService;
  final Map<String, _PendingCloudinaryTrack> _drafts = {};

  @override
  Future<UploadQuota> getUploadQuota(String userId) async {
    return const UploadQuota(
      tier: 'free',
      uploadMinutesLimit: 180,
      uploadMinutesUsed: 8,
      uploadMinutesRemaining: 172,
      canReplaceFiles: false,
      canScheduleRelease: false,
      canAccessAdvancedTab: false,
    );
  }

  @override
  Future<UploadedTrack> createTrack(String userId) async {
    final trackId = 'track_${DateTime.now().millisecondsSinceEpoch}';
    _drafts[trackId] = _PendingCloudinaryTrack(
      trackId: trackId,
      createdAt: DateTime.now(),
    );

    return UploadedTrack(
      trackId: trackId,
      status: UploadStatus.idle,
    );
  }

  @override
  Future<UploadedTrack> uploadAudio({
    required String trackId,
    required PickedUploadFile file,
    required void Function(double progress) onProgress,
  }) async {
    final uploadedAudio = await _mediaService.uploadAudio(
      filePath: file.path,
      fileName: file.name,
      onSendProgress: (sent, total) {
        if (total > 0) {
          onProgress(sent / total);
        }
      },
    );

    final current = _drafts[trackId] ?? _PendingCloudinaryTrack(trackId: trackId, createdAt: DateTime.now());
    _drafts[trackId] = current.copyWith(
      audioUrl: uploadedAudio.secureUrl,
      audioPublicId: uploadedAudio.publicId,
      waveformUrl: _mediaService.buildWaveformImageUrl(audioPublicId: uploadedAudio.publicId),
      durationSeconds: uploadedAudio.durationSeconds ?? 0,
      localFilePath: file.path,
    );

    return UploadedTrack(
      trackId: trackId,
      status: UploadStatus.processing,
      audioUrl: uploadedAudio.secureUrl,
      waveformUrl: _drafts[trackId]?.waveformUrl,
      durationSeconds: uploadedAudio.durationSeconds,
    );
  }

  @override
  Future<UploadedTrack> finalizeMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final current = _drafts[trackId];
    if (current == null || current.audioUrl == null) {
      throw StateError('Audio must be uploaded before metadata is finalized.');
    }

    String? artworkUrl = current.artworkUrl;
    String? localArtworkPath = current.localArtworkPath;
    final rawArtworkPath = metadata.artworkPath?.trim();

    if (rawArtworkPath != null && rawArtworkPath.isNotEmpty) {
      if (_isRemoteUrl(rawArtworkPath)) {
        artworkUrl = rawArtworkPath;
        localArtworkPath = current.localArtworkPath;
      } else {
        final artworkFileName = _fileNameFromPath(rawArtworkPath);
        final uploadedArtwork = await _mediaService.uploadArtwork(
          filePath: rawArtworkPath,
          fileName: artworkFileName,
        );
        artworkUrl = uploadedArtwork.secureUrl;
        localArtworkPath = rawArtworkPath;
      }
    }

    final updated = current.copyWith(
      title: metadata.title,
      description: metadata.description,
      privacy: metadata.privacy,
      artists: metadata.artists,
      tags: metadata.tags,
      genreCategory: metadata.genreCategory,
      genreSubGenre: metadata.genreSubGenre,
      recordLabel: metadata.recordLabel,
      publisher: metadata.publisher,
      isrc: metadata.isrc,
      pLine: metadata.pLine,
      contentWarning: metadata.contentWarning,
      scheduledReleaseDate: metadata.scheduledReleaseDate,
      allowDownloads: metadata.allowDownloads,
      offlineListening: metadata.offlineListening,
      includeInRss: metadata.includeInRss,
      displayEmbedCode: metadata.displayEmbedCode,
      appPlaybackEnabled: metadata.appPlaybackEnabled,
      availabilityType: metadata.availabilityType,
      availabilityRegions: metadata.availabilityRegions,
      licensing: metadata.licensing,
      artworkUrl: artworkUrl,
      localArtworkPath: localArtworkPath,
    );

    _drafts[trackId] = updated;
    _saveToGlobalStore(updated, status: UploadProcessingStatus.processing);

    return UploadedTrack(
      trackId: trackId,
      status: UploadStatus.processing,
      audioUrl: updated.audioUrl,
      waveformUrl: updated.waveformUrl,
      title: updated.title,
      description: updated.description,
      privacy: updated.privacy,
      artworkUrl: updated.artworkUrl,
      durationSeconds: updated.durationSeconds,
    );
  }

  @override
  Future<UploadedTrack> waitUntilProcessed(String trackId) async {
    final current = _drafts[trackId];
    if (current == null) {
      throw StateError('Track draft not found for $trackId');
    }

    await Future.delayed(const Duration(milliseconds: 900));
    _saveToGlobalStore(current, status: UploadProcessingStatus.finished);

    return UploadedTrack(
      trackId: trackId,
      status: UploadStatus.finished,
      audioUrl: current.audioUrl,
      waveformUrl: current.waveformUrl,
      title: current.title,
      description: current.description,
      privacy: current.privacy,
      artworkUrl: current.artworkUrl,
      durationSeconds: current.durationSeconds,
    );
  }

  @override
  Future<UploadedTrack> getTrackDetails(String trackId) async {
    final item = GlobalTrackStore.instance.find(trackId);
    if (item == null) {
      throw StateError('Track not found: $trackId');
    }

    return UploadedTrack(
      trackId: item.id,
      status: _mapStatus(item.status),
      audioUrl: item.audioUrl,
      waveformUrl: item.waveformUrl,
      title: item.title,
      description: item.description,
      privacy: item.visibility == UploadVisibility.public ? 'public' : 'private',
      artworkUrl: item.artworkUrl,
      durationSeconds: item.durationSeconds,
    );
  }

  @override
  Future<UploadedTrack> updateTrackMetadata({
    required String trackId,
    required TrackMetadata metadata,
  }) async {
    final existing = GlobalTrackStore.instance.find(trackId);
    final current = _drafts[trackId] ?? _PendingCloudinaryTrack.maybeFromUploadItem(existing);

    if (current == null) {
      throw StateError('Track not found: $trackId');
    }

    String? artworkUrl = current.artworkUrl;
    String? localArtworkPath = current.localArtworkPath;
    final rawArtworkPath = metadata.artworkPath?.trim();

    if (rawArtworkPath != null && rawArtworkPath.isNotEmpty) {
      if (_isRemoteUrl(rawArtworkPath)) {
        artworkUrl = rawArtworkPath;
      } else {
        final uploadedArtwork = await _mediaService.uploadArtwork(
          filePath: rawArtworkPath,
          fileName: _fileNameFromPath(rawArtworkPath),
        );
        artworkUrl = uploadedArtwork.secureUrl;
        localArtworkPath = rawArtworkPath;
      }
    }

    final updated = current.copyWith(
      title: metadata.title,
      description: metadata.description,
      privacy: metadata.privacy,
      artists: metadata.artists,
      tags: metadata.tags,
      genreCategory: metadata.genreCategory,
      genreSubGenre: metadata.genreSubGenre,
      recordLabel: metadata.recordLabel,
      publisher: metadata.publisher,
      isrc: metadata.isrc,
      pLine: metadata.pLine,
      contentWarning: metadata.contentWarning,
      scheduledReleaseDate: metadata.scheduledReleaseDate,
      allowDownloads: metadata.allowDownloads,
      offlineListening: metadata.offlineListening,
      includeInRss: metadata.includeInRss,
      displayEmbedCode: metadata.displayEmbedCode,
      appPlaybackEnabled: metadata.appPlaybackEnabled,
      availabilityType: metadata.availabilityType,
      availabilityRegions: metadata.availabilityRegions,
      licensing: metadata.licensing,
      artworkUrl: artworkUrl,
      localArtworkPath: localArtworkPath,
    );

    _drafts[trackId] = updated;
    _saveToGlobalStore(updated, status: UploadProcessingStatus.finished);

    return UploadedTrack(
      trackId: trackId,
      status: UploadStatus.finished,
      audioUrl: updated.audioUrl,
      waveformUrl: updated.waveformUrl,
      title: updated.title,
      description: updated.description,
      privacy: updated.privacy,
      artworkUrl: updated.artworkUrl,
      durationSeconds: updated.durationSeconds,
    );
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    GlobalTrackStore.instance.remove(trackId);
    _drafts.remove(trackId);
  }

  void _saveToGlobalStore(
    _PendingCloudinaryTrack draft, {
    required UploadProcessingStatus status,
  }) {
    final item = UploadItem(
      id: draft.trackId,
      title: draft.title?.trim().isNotEmpty == true ? draft.title!.trim() : 'Untitled',
      artistDisplay: draft.artists.isEmpty ? 'Authenticated artist' : draft.artists.join(', '),
      durationLabel: _formatDuration(draft.durationSeconds),
      durationSeconds: draft.durationSeconds,
      audioUrl: draft.audioUrl,
      waveformUrl: draft.waveformUrl,
      artworkUrl: draft.artworkUrl,
      localArtworkPath: draft.localArtworkPath,
      localFilePath: draft.localFilePath,
      description: draft.description,
      tags: draft.tags,
      genreCategory: draft.genreCategory,
      genreSubGenre: draft.genreSubGenre,
      visibility: draft.privacy == 'public' ? UploadVisibility.public : UploadVisibility.private,
      status: status,
      isExplicit: draft.contentWarning,
      recordLabel: draft.recordLabel,
      publisher: draft.publisher,
      isrc: draft.isrc,
      pLine: draft.pLine,
      scheduledReleaseDate: draft.scheduledReleaseDate,
      allowDownloads: draft.allowDownloads,
      offlineListening: draft.offlineListening,
      includeInRss: draft.includeInRss,
      displayEmbedCode: draft.displayEmbedCode,
      appPlaybackEnabled: draft.appPlaybackEnabled,
      availabilityType: draft.availabilityType,
      availabilityRegions: draft.availabilityRegions,
      licensing: draft.licensing,
      createdAt: draft.createdAt,
    );

    GlobalTrackStore.instance.add(item);
  }

  UploadStatus _mapStatus(UploadProcessingStatus status) {
    switch (status) {
      case UploadProcessingStatus.processing:
        return UploadStatus.processing;
      case UploadProcessingStatus.finished:
        return UploadStatus.finished;
      case UploadProcessingStatus.failed:
        return UploadStatus.failed;
      case UploadProcessingStatus.deleted:
        return UploadStatus.deleted;
    }
  }

  static bool _isRemoteUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  static String _fileNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? path : parts.last;
  }

  static String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PendingCloudinaryTrack {
  const _PendingCloudinaryTrack({
    required this.trackId,
    required this.createdAt,
    this.audioUrl,
    this.audioPublicId,
    this.waveformUrl,
    this.artworkUrl,
    this.localArtworkPath,
    this.localFilePath,
    this.durationSeconds = 0,
    this.title,
    this.description,
    this.privacy = 'public',
    this.artists = const [],
    this.tags = const [],
    this.genreCategory = '',
    this.genreSubGenre = '',
    this.recordLabel = '',
    this.publisher = '',
    this.isrc = '',
    this.pLine = '',
    this.contentWarning = false,
    this.scheduledReleaseDate,
    this.allowDownloads = false,
    this.offlineListening = true,
    this.includeInRss = true,
    this.displayEmbedCode = true,
    this.appPlaybackEnabled = true,
    this.availabilityType = 'worldwide',
    this.availabilityRegions = const [],
    this.licensing = 'all_rights_reserved',
  });

  final String trackId;
  final DateTime createdAt;
  final String? audioUrl;
  final String? audioPublicId;
  final String? waveformUrl;
  final String? artworkUrl;
  final String? localArtworkPath;
  final String? localFilePath;
  final int durationSeconds;
  final String? title;
  final String? description;
  final String privacy;
  final List<String> artists;
  final List<String> tags;
  final String genreCategory;
  final String genreSubGenre;
  final String recordLabel;
  final String publisher;
  final String isrc;
  final String pLine;
  final bool contentWarning;
  final DateTime? scheduledReleaseDate;
  final bool allowDownloads;
  final bool offlineListening;
  final bool includeInRss;
  final bool displayEmbedCode;
  final bool appPlaybackEnabled;
  final String availabilityType;
  final List<String> availabilityRegions;
  final String licensing;

  static _PendingCloudinaryTrack? maybeFromUploadItem(UploadItem? item) {
    if (item == null) {
      return null;
    }

    return _PendingCloudinaryTrack(
      trackId: item.id,
      createdAt: item.createdAt,
      audioUrl: item.audioUrl,
      waveformUrl: item.waveformUrl,
      artworkUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
      localFilePath: item.localFilePath,
      durationSeconds: item.durationSeconds,
      title: item.title,
      description: item.description,
      privacy: item.visibility == UploadVisibility.public ? 'public' : 'private',
      artists: item.artistDisplay
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      tags: item.tags,
      genreCategory: item.genreCategory,
      genreSubGenre: item.genreSubGenre,
      recordLabel: item.recordLabel,
      publisher: item.publisher,
      isrc: item.isrc,
      pLine: item.pLine,
      contentWarning: item.isExplicit,
      scheduledReleaseDate: item.scheduledReleaseDate,
      allowDownloads: item.allowDownloads,
      offlineListening: item.offlineListening,
      includeInRss: item.includeInRss,
      displayEmbedCode: item.displayEmbedCode,
      appPlaybackEnabled: item.appPlaybackEnabled,
      availabilityType: item.availabilityType,
      availabilityRegions: item.availabilityRegions,
      licensing: item.licensing,
    );
  }

  _PendingCloudinaryTrack copyWith({
    String? audioUrl,
    String? audioPublicId,
    String? waveformUrl,
    String? artworkUrl,
    String? localArtworkPath,
    String? localFilePath,
    int? durationSeconds,
    String? title,
    String? description,
    String? privacy,
    List<String>? artists,
    List<String>? tags,
    String? genreCategory,
    String? genreSubGenre,
    String? recordLabel,
    String? publisher,
    String? isrc,
    String? pLine,
    bool? contentWarning,
    DateTime? scheduledReleaseDate,
    bool? allowDownloads,
    bool? offlineListening,
    bool? includeInRss,
    bool? displayEmbedCode,
    bool? appPlaybackEnabled,
    String? availabilityType,
    List<String>? availabilityRegions,
    String? licensing,
  }) {
    return _PendingCloudinaryTrack(
      trackId: trackId,
      createdAt: createdAt,
      audioUrl: audioUrl ?? this.audioUrl,
      audioPublicId: audioPublicId ?? this.audioPublicId,
      waveformUrl: waveformUrl ?? this.waveformUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      localArtworkPath: localArtworkPath ?? this.localArtworkPath,
      localFilePath: localFilePath ?? this.localFilePath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      title: title ?? this.title,
      description: description ?? this.description,
      privacy: privacy ?? this.privacy,
      artists: artists ?? this.artists,
      tags: tags ?? this.tags,
      genreCategory: genreCategory ?? this.genreCategory,
      genreSubGenre: genreSubGenre ?? this.genreSubGenre,
      recordLabel: recordLabel ?? this.recordLabel,
      publisher: publisher ?? this.publisher,
      isrc: isrc ?? this.isrc,
      pLine: pLine ?? this.pLine,
      contentWarning: contentWarning ?? this.contentWarning,
      scheduledReleaseDate: scheduledReleaseDate ?? this.scheduledReleaseDate,
      allowDownloads: allowDownloads ?? this.allowDownloads,
      offlineListening: offlineListening ?? this.offlineListening,
      includeInRss: includeInRss ?? this.includeInRss,
      displayEmbedCode: displayEmbedCode ?? this.displayEmbedCode,
      appPlaybackEnabled: appPlaybackEnabled ?? this.appPlaybackEnabled,
      availabilityType: availabilityType ?? this.availabilityType,
      availabilityRegions: availabilityRegions ?? this.availabilityRegions,
      licensing: licensing ?? this.licensing,
    );
  }
}
