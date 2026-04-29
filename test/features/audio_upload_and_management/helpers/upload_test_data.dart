import 'package:software_project/features/audio_upload_and_management/domain/entities/artist_tools_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/picked_upload_file.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/track_metadata.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_item.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_quota.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_status.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/uploaded_track.dart';

const samplePickedUploadFile = PickedUploadFile(
  name: 'track.mp3',
  path: '/tmp/track.mp3',
  sizeBytes: 2048,
  durationSeconds: 245,
);
const sampleUploadQuota = UploadQuota(
  tier: 'free',
  uploadMinutesLimit: 180,
  uploadMinutesUsed: 12,
  uploadMinutesRemaining: 168,
  canReplaceFiles: false,
  canScheduleRelease: false,
  canAccessAdvancedTab: false,
);

const sampleArtistToolsQuota = ArtistToolsQuota(
  tier: ArtistTier.free,
  uploadMinutesLimit: 180,
  uploadMinutesUsed: 12,
  canReplaceFiles: false,
);

const sampleUploadedTrack = UploadedTrack(
  trackId: 'track-1',
  status: UploadStatus.processing,
  audioUrl: 'https://cdn.example.com/audio/track-1.mp3',
  waveformUrl: 'https://cdn.example.com/waveform/track-1.json',
  title: 'Midnight Echo',
  description: 'Synth demo',
  privacy: 'public',
  artworkUrl: 'https://cdn.example.com/artwork/track-1.png',
  durationSeconds: 245,
);

final sampleTrackMetadata = TrackMetadata(
  title: 'Midnight Echo',
  genreCategory: 'music',
  genreSubGenre: 'hiphop',
  tags: const ['night', 'beats'],
  description: 'Synth demo',
  privacy: 'public',
  artists: const ['Kevin'],
  artworkPath: null,
  recordLabel: 'Night Records',
  publisher: 'Moon Publishing',
  isrc: 'US-S1Z-99-00001',
  pLine: '2026 Night Records',
  contentWarning: false,
  scheduledReleaseDate: DateTime.utc(2026, 4, 1),
  allowDownloads: false,
  offlineListening: true,
  includeInRss: true,
  displayEmbedCode: true,
  appPlaybackEnabled: true,
  availabilityType: 'worldwide',
  availabilityRegions: const [],
  licensing: 'creative_commons',
);

final sampleUploadItem = UploadItem(
  id: 'track-1',
  title: 'Midnight Echo',
  artistDisplay: 'Kevin',
  durationLabel: '4:05',
  durationSeconds: 245,
  audioUrl: 'https://cdn.example.com/audio/track-1.mp3',
  waveformUrl: 'https://cdn.example.com/waveform/track-1.json',
  waveformBars: const [0.2, 0.4, 0.6],
  artworkUrl: 'https://cdn.example.com/artwork/track-1.png',
  description: 'Synth demo',
  tags: const ['night', 'beats'],
  genreCategory: 'music',
  genreSubGenre: 'hiphop',
  visibility: UploadVisibility.public,
  status: UploadProcessingStatus.finished,
  isExplicit: false,
  recordLabel: 'Night Records',
  publisher: 'Moon Publishing',
  isrc: 'US-S1Z-99-00001',
  pLine: '2026 Night Records',
  allowDownloads: false,
  offlineListening: true,
  includeInRss: true,
  displayEmbedCode: true,
  appPlaybackEnabled: true,
  availabilityType: 'worldwide',
  availabilityRegions: const [],
  licensing: 'creative_commons',
  createdAt: DateTime.utc(2026, 3, 1),
);

Map<String, dynamic> sampleUploadQuotaJson() => {
  'tier': 'free',
  'uploadMinutesLimit': 180,
  'uploadMinutesUsed': 12,
  'uploadMinutesRemaining': 168,
  'canReplaceFiles': false,
  'canScheduleRelease': false,
  'canAccessAdvancedTab': false,
};

Map<String, dynamic> sampleTrackResponseJson({
  String status = 'processing',
  Map<String, dynamic>? error,
}) => {
  'trackId': 'track-1',
  'status': status,
  'title': 'Midnight Echo',
  'description': 'Synth demo',
  'genre': 'music_hiphop',
  'tags': ['night', 'beats'],
  'artists': ['Kevin'],
  'durationSeconds': 245,
  'privacy': 'public',
  'scheduledReleaseDate': '2026-04-01T00:00:00.000Z',
  'availability': {'type': 'worldwide', 'regions': <String>[]},
  'licensing': {
    'type': 'creative_commons',
    'allowAttribution': true,
    'nonCommercial': true,
    'noDerivatives': false,
    'shareAlike': true,
  },
  'permissions': {
    'enableDirectDownloads': false,
    'enableOfflineListening': true,
    'includeInRSS': true,
    'displayEmbedCode': true,
    'enableAppPlayback': true,
    'allowComments': true,
    'showCommentsPublic': true,
    'showInsightsPublic': false,
  },
  'recordLabel': 'Night Records',
  'publisher': 'Moon Publishing',
  'isrc': 'US-S1Z-99-00001',
  'pLine': '2026 Night Records',
  'contentWarning': false,
  'audioUrl': 'https://cdn.example.com/audio/track-1.mp3',
  'waveformUrl': 'https://cdn.example.com/waveform/track-1.json',
  'artworkUrl': 'https://cdn.example.com/artwork/track-1.png',
  'createdAt': '2026-03-01T00:00:00.000Z',
  'updatedAt': '2026-03-02T00:00:00.000Z',
  'audioMetadata': {
    'bitrateKbps': 320,
    'sampleRateHz': 44100,
    'format': 'mp3',
    'fileSizeBytes': 10485760,
  },
  // ignore: use_null_aware_elements
  if (error != null) 'error': error,
};

Map<String, dynamic> sampleUploadItemJson({
  String privacy = 'public',
  String status = 'finished',
}) => {
  'id': 'track-1',
  'title': 'Midnight Echo',
  'artists': ['Kevin'],
  'durationSeconds': 245,
  'audioUrl': 'https://cdn.example.com/audio/track-1.mp3',
  'waveformUrl': 'https://cdn.example.com/waveform/track-1.json',
  'waveformBars': [0.2, 0.4, 0.6],
  'artworkUrl': 'https://cdn.example.com/artwork/track-1.png',
  'description': 'Synth demo',
  'tags': ['night', 'beats'],
  'genreCategory': 'music',
  'genreSubGenre': 'hiphop',
  'privacy': privacy,
  'status': status,
  'contentWarning': false,
  'recordLabel': 'Night Records',
  'publisher': 'Moon Publishing',
  'isrc': 'US-S1Z-99-00001',
  'pLine': '2026 Night Records',
  'scheduledReleaseDate': '2026-04-01T00:00:00.000Z',
  'allowDownloads': false,
  'offlineListening': true,
  'includeInRss': true,
  'displayEmbedCode': true,
  'appPlaybackEnabled': true,
  'availabilityType': 'worldwide',
  'availabilityRegions': <String>[],
  'licensing': 'creative_commons',
  'createdAt': '2026-03-01T00:00:00.000Z',
};

Map<String, dynamic> sampleArtistToolsQuotaJson() => {
  'tier': 'free',
  'uploadMinutesLimit': 180,
  'uploadMinutesUsed': 12,
  'canReplaceFiles': false,
  'canUpgrade': true,
};
