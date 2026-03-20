import '../../domain/entities/upload_item.dart';
import 'global_track_store.dart';

void persistMockTrackToStore(
  Map<String, dynamic> data,
  Map<String, String> localFilePaths,
) {
  final trackId = data['trackId'] as String;
  final artists =
      (data['artists'] as List?)?.map((entry) => entry.toString()).toList() ??
      ['Unknown'];
  final artworkUrl = data['artworkUrl'] as String?;
  final ownerUserId = (data['ownerUserId'] as String?)?.trim();

  GlobalTrackStore.instance.add(
    UploadItem(
      id: trackId,
      title: (data['title'] as String?)?.trim().isEmpty == true
          ? 'Untitled'
          : (data['title'] as String?) ?? 'Untitled',
      artistDisplay: artists.join(', '),
      durationLabel: formatMockDuration((data['durationSeconds'] as int?) ?? 0),
      durationSeconds: (data['durationSeconds'] as int?) ?? 0,
      audioUrl: data['audioUrl'] as String?,
      waveformUrl: data['waveformUrl'] as String?,
      waveformBars: (data['waveformBars'] as List?)
          ?.map((entry) => (entry as num?)?.toDouble())
          .whereType<double>()
          .toList(),
      artworkUrl: artworkUrl,
      localArtworkPath: (artworkUrl != null && !artworkUrl.startsWith('http'))
          ? artworkUrl
          : null,
      localFilePath: localFilePaths[trackId],
      description: data['description'] as String?,
      tags:
          (data['tags'] as List?)?.map((entry) => entry.toString()).toList() ??
          const [],
      genreCategory: (data['genreCategory'] as String?) ?? '',
      genreSubGenre: (data['genreSubGenre'] as String?) ?? '',
      visibility: (data['privacy'] as String?) == 'public'
          ? UploadVisibility.public
          : UploadVisibility.private,
      status:
          ((data['status'] as String?) == 'processing' ||
              (data['status'] as String?) == 'uploading')
          ? UploadProcessingStatus.processing
          : UploadProcessingStatus.finished,
      isExplicit: (data['contentWarning'] as bool?) ?? false,
      recordLabel: (data['recordLabel'] as String?) ?? '',
      publisher: (data['publisher'] as String?) ?? '',
      isrc: (data['isrc'] as String?) ?? '',
      pLine: (data['pLine'] as String?) ?? '',
      scheduledReleaseDate: DateTime.tryParse(
        data['scheduledReleaseDate'] as String? ?? '',
      ),
      allowDownloads: (data['allowDownloads'] as bool?) ?? false,
      offlineListening: (data['offlineListening'] as bool?) ?? true,
      includeInRss: (data['includeInRss'] as bool?) ?? true,
      displayEmbedCode: (data['displayEmbedCode'] as bool?) ?? true,
      appPlaybackEnabled: (data['appPlaybackEnabled'] as bool?) ?? true,
      availabilityType: (data['availabilityType'] as String?) ?? 'worldwide',
      availabilityRegions:
          (data['availabilityRegions'] as List?)
              ?.map((entry) => entry.toString())
              .toList() ??
          const [],
      licensing: (data['licensing'] as String?) ?? 'all_rights_reserved',
      createdAt:
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
    ),
    ownerUserId: ownerUserId == null || ownerUserId.isEmpty
        ? '__global__'
        : ownerUserId,
  );
}

String formatMockDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
