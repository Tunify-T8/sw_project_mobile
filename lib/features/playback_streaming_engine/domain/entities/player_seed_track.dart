import 'playability_info.dart';
import 'playback_status.dart';
import 'preview_info.dart';
import 'stream_url.dart';
import 'track_artist_summary.dart';
import 'track_engagement.dart';
import 'track_playback_bundle.dart';

/// Lightweight fallback data used when we want to launch the player from
/// Module 4 immediately using already-known upload details.
///
/// [resumePositionSeconds] is local-only Flutter state. It lets History and
/// Recently Played resume from where the user stopped even when the backend
/// does not store listening progress.
class PlayerSeedTrack {
  const PlayerSeedTrack({
    required this.trackId,
    required this.title,
    required this.artistName,
    required this.durationSeconds,
    this.coverUrl,
    this.waveformUrl,
    this.directAudioUrl,
    this.localFilePath,
    this.resumePositionSeconds = 0,
    this.playability,
  });

  final String trackId;
  final String title;
  final String artistName;
  final int durationSeconds;
  final String? coverUrl;
  final String? waveformUrl;
  final String? directAudioUrl;
  final String? localFilePath;
  final int resumePositionSeconds;
  final PlayabilityInfo? playability;

  TrackPlaybackBundle toPlaybackBundle() {
    return TrackPlaybackBundle(
      trackId: trackId,
      title: title,
      artist: TrackArtistSummary(
        id: '',
        name: artistName,
      ),
      durationSeconds: durationSeconds,
      waveformUrl: waveformUrl ?? '',
      coverUrl: coverUrl ?? '',
      contentWarning: false,
      engagement: const TrackEngagement(
        likeCount: 0,
        commentCount: 0,
        repostCount: 0,
        isLiked: false,
        isReposted: false,
        isSaved: false,
      ),
      playability: playability ?? const PlayabilityInfo(
        status: PlaybackStatus.playable,
        regionBlocked: false,
        tierBlocked: false,
        requiresSubscription: false,
      ),
      preview: const PreviewInfo(
        enabled: false,
        previewDurationSeconds: 30,
        previewStartSeconds: 0,
      ),
    );
  }

  StreamUrl? toDirectStreamUrl() {
    if (directAudioUrl == null || directAudioUrl!.trim().isEmpty) {
      return null;
    }

    return StreamUrl(
      trackId: trackId,
      url: directAudioUrl!,
      expiresInSeconds: 86400,
      format: _inferFormat(directAudioUrl!),
    );
  }

  static String _inferFormat(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.wav')) return 'wav';
    if (lower.endsWith('.flac')) return 'flac';
    if (lower.endsWith('.aac')) return 'aac';
    if (lower.endsWith('.ogg')) return 'ogg';
    if (lower.endsWith('.m3u8')) return 'hls';
    return 'mp3';
  }
}
