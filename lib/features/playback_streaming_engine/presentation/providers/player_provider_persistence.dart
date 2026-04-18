part of 'player_provider.dart';

extension _PlayerNotifierPersistence on PlayerNotifier {
  void _attachLifecycleObserver() {
    if (_lifecycleObserverAttached) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserverAttached = true;
  }

  void _detachLifecycleObserver() {
    if (!_lifecycleObserverAttached) return;
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleObserverAttached = false;
  }

  void _handleLifecycleStateChanged(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      unawaited(_persistCurrentSession(force: true));

      final current = _current;
      if (current?.bundle != null) {
        unawaited(
          _safeReportEvent(
            PlaybackEvent(
              trackId: current!.bundle!.trackId,
              action: current.isPlaying
                  ? PlaybackAction.progress
                  : PlaybackAction.pause,
              positionSeconds: current.positionSeconds.round(),
            ),
          ),
        );
      }
    }
  }

  Future<PlayerState> _restorePersistedSession() async {
    final raw = await PlayerNotifier._storage.read(
      key: StorageKeys.cachedPlayerSession,
    );
    if (raw == null || raw.isEmpty) {
      return const PlayerState();
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final bundleJson = decoded['bundle'] as Map<String, dynamic>?;
      if (bundleJson == null) {
        return const PlayerState();
      }

      final restored = PlayerState(
        bundle: _bundleFromJson(bundleJson),
        streamUrl: decoded['streamUrl'] is Map<String, dynamic>
            ? _streamUrlFromJson(decoded['streamUrl'] as Map<String, dynamic>)
            : null,
        queue: decoded['queue'] is Map<String, dynamic>
            ? _queueFromJson(decoded['queue'] as Map<String, dynamic>)
            : null,
        isPlaying: false,
        positionSeconds: (decoded['positionSeconds'] as num?)?.toDouble() ?? 0,
        isMuted: decoded['isMuted'] as bool? ?? false,
        volume: (decoded['volume'] as num?)?.toDouble() ?? 1.0,
        isBuffering: false,
        streamExpiresAt: decoded['streamExpiresAt'] == null
            ? null
            : DateTime.tryParse(decoded['streamExpiresAt'].toString()),
        localFilePath: decoded['localFilePath'] as String?,
        mediaDurationSeconds: (decoded['mediaDurationSeconds'] as num?)
            ?.toDouble(),
      );

      try {
        final expiresAt = restored.streamExpiresAt;
        final hasUsableRemoteSource =
            restored.streamUrl != null &&
            (expiresAt == null || DateTime.now().isBefore(expiresAt));

        if ((restored.localFilePath?.trim().isNotEmpty == true) ||
            hasUsableRemoteSource) {
          await _prepareAudioSource(restored, force: true);
          await _applyVolume(restored);
          if (restored.positionSeconds > 0) {
            await _audioPlayer.seek(
              Duration(milliseconds: (restored.positionSeconds * 1000).round()),
            );
          }
        }
      } catch (_) {
        // The UI can still restore from cached state even if the source needs
        // to be refreshed later when the user presses play.
      }

      return restored;
    } catch (_) {
      await PlayerNotifier._storage.delete(
        key: StorageKeys.cachedPlayerSession,
      );
      return const PlayerState();
    }
  }

  Future<void> _persistCurrentSession({
    PlayerState? playerState,
    bool force = false,
  }) async {
    final current = playerState ?? _current;
    if (current == null || current.bundle == null) {
      await PlayerNotifier._storage.delete(
        key: StorageKeys.cachedPlayerSession,
      );
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _lastSessionPersistAt != null &&
        now.difference(_lastSessionPersistAt!) <
            const Duration(milliseconds: 700)) {
      return;
    }
    _lastSessionPersistAt = now;

    final payload = <String, dynamic>{
      'bundle': _bundleToJson(current.bundle!),
      'streamUrl': current.streamUrl == null
          ? null
          : _streamUrlToJson(current.streamUrl!),
      'queue': current.queue == null ? null : _queueToJson(current.queue!),
      'positionSeconds': current.positionSeconds,
      'isMuted': current.isMuted,
      'volume': current.volume,
      'streamExpiresAt': current.streamExpiresAt?.toIso8601String(),
      'localFilePath': current.localFilePath,
      'mediaDurationSeconds': current.mediaDurationSeconds,
    };

    await PlayerNotifier._storage.write(
      key: StorageKeys.cachedPlayerSession,
      value: jsonEncode(payload),
    );
  }

  Map<String, dynamic> _bundleToJson(TrackPlaybackBundle bundle) {
    return {
      'trackId': bundle.trackId,
      'title': bundle.title,
      'artist': {
        'id': bundle.artist.id,
        'name': bundle.artist.name,
        'username': bundle.artist.username,
        'displayName': bundle.artist.displayName,
        'avatarUrl': bundle.artist.avatarUrl,
        'tier': bundle.artist.tier,
      },
      'durationSeconds': bundle.durationSeconds,
      'waveformUrl': bundle.waveformUrl,
      'coverUrl': bundle.coverUrl,
      'contentWarning': bundle.contentWarning,
      'engagement': {
        'likeCount': bundle.engagement.likeCount,
        'commentCount': bundle.engagement.commentCount,
        'repostCount': bundle.engagement.repostCount,
        'isLiked': bundle.engagement.isLiked,
        'isReposted': bundle.engagement.isReposted,
        'isSaved': bundle.engagement.isSaved,
      },
      'playability': {
        'status': _playbackStatusToString(bundle.playability.status),
        'regionBlocked': bundle.playability.regionBlocked,
        'tierBlocked': bundle.playability.tierBlocked,
        'requiresSubscription': bundle.playability.requiresSubscription,
        'blockedReason': bundle.playability.blockedReason?.name,
      },
      'preview': {
        'enabled': bundle.preview.enabled,
        'previewDurationSeconds': bundle.preview.previewDurationSeconds,
        'previewStartSeconds': bundle.preview.previewStartSeconds,
      },
      'scheduledReleaseDate': bundle.scheduledReleaseDate?.toIso8601String(),
    };
  }

  TrackPlaybackBundle _bundleFromJson(Map<String, dynamic> json) {
    final artistJson =
        json['artist'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final engagementJson =
        json['engagement'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final playabilityJson =
        json['playability'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final previewJson =
        json['preview'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return TrackPlaybackBundle(
      trackId: (json['trackId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      artist: TrackArtistSummary(
        id: (artistJson['id'] ?? '') as String,
        name: (artistJson['name'] ?? '') as String,
        username: artistJson['username'] as String?,
        displayName: artistJson['displayName'] as String?,
        avatarUrl: artistJson['avatarUrl'] as String?,
        tier: artistJson['tier'] as String?,
      ),
      durationSeconds: (json['durationSeconds'] as int?) ?? 0,
      waveformUrl: (json['waveformUrl'] ?? '') as String,
      coverUrl: (json['coverUrl'] ?? '') as String,
      contentWarning: json['contentWarning'] as bool? ?? false,
      engagement: TrackEngagement(
        likeCount: (engagementJson['likeCount'] as int?) ?? 0,
        commentCount: (engagementJson['commentCount'] as int?) ?? 0,
        repostCount: (engagementJson['repostCount'] as int?) ?? 0,
        isLiked: engagementJson['isLiked'] as bool? ?? false,
        isReposted: engagementJson['isReposted'] as bool? ?? false,
        isSaved: engagementJson['isSaved'] as bool? ?? false,
      ),
      playability: PlayabilityInfo(
        status: _playbackStatusFromString(
          (playabilityJson['status'] ?? 'playable').toString(),
        ),
        regionBlocked: playabilityJson['regionBlocked'] as bool? ?? false,
        tierBlocked: playabilityJson['tierBlocked'] as bool? ?? false,
        requiresSubscription:
            playabilityJson['requiresSubscription'] as bool? ?? false,
        blockedReason: _blockedReasonFromString(
          playabilityJson['blockedReason']?.toString(),
        ),
      ),
      preview: PreviewInfo(
        enabled: previewJson['enabled'] as bool? ?? false,
        previewDurationSeconds:
            (previewJson['previewDurationSeconds'] as int?) ?? 30,
        previewStartSeconds: (previewJson['previewStartSeconds'] as int?) ?? 0,
      ),
      scheduledReleaseDate: json['scheduledReleaseDate'] == null
          ? null
          : DateTime.tryParse(json['scheduledReleaseDate'].toString()),
    );
  }

  Map<String, dynamic> _streamUrlToJson(StreamUrl streamUrl) {
    return {
      'trackId': streamUrl.trackId,
      'url': streamUrl.url,
      'expiresInSeconds': streamUrl.expiresInSeconds,
      'format': streamUrl.format,
    };
  }

  StreamUrl _streamUrlFromJson(Map<String, dynamic> json) {
    return StreamUrl(
      trackId: (json['trackId'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      expiresInSeconds: (json['expiresInSeconds'] as int?) ?? 600,
      format: (json['format'] ?? 'mp3') as String,
    );
  }

  Map<String, dynamic> _queueToJson(PlaybackQueue queue) {
    return {
      'trackIds': queue.trackIds,
      'currentIndex': queue.currentIndex,
      'shuffle': queue.shuffle,
      'repeat': _repeatModeToString(queue.repeat),
      // Pre-shuffle snapshot so unshuffling after an app restart still works.
      if (queue.originalTrackIds != null)
        'originalTrackIds': queue.originalTrackIds,
    };
  }

  PlaybackQueue _queueFromJson(Map<String, dynamic> json) {
    final rawTrackIds = json['trackIds'] as List<dynamic>? ?? const <dynamic>[];
    final rawOriginal = json['originalTrackIds'] as List<dynamic>?;
    return PlaybackQueue(
      trackIds: rawTrackIds
          .map((value) => value.toString())
          .toList(growable: false),
      currentIndex: (json['currentIndex'] as int?) ?? 0,
      shuffle: json['shuffle'] as bool? ?? false,
      repeat: _repeatModeFromString((json['repeat'] ?? 'none').toString()),
      originalTrackIds: rawOriginal
          ?.map((value) => value.toString())
          .toList(growable: false),
    );
  }

  String _playbackStatusToString(PlaybackStatus status) {
    switch (status) {
      case PlaybackStatus.playable:
        return 'playable';
      case PlaybackStatus.preview:
        return 'preview';
      case PlaybackStatus.blocked:
        return 'blocked';
    }
  }

  PlaybackStatus _playbackStatusFromString(String value) {
    switch (value) {
      case 'preview':
        return PlaybackStatus.preview;
      case 'blocked':
        return PlaybackStatus.blocked;
      default:
        return PlaybackStatus.playable;
    }
  }

  BlockedReason? _blockedReasonFromString(String? value) {
    switch (value) {
      case 'region_restricted':
        return BlockedReason.regionRestricted;
      case 'tier_restricted':
        return BlockedReason.tierRestricted;
      case 'scheduled_release':
        return BlockedReason.scheduledRelease;
      case 'deleted':
        return BlockedReason.deleted;
      case 'private_no_token':
        return BlockedReason.privateNoToken;
      case 'copyright':
        return BlockedReason.copyright;
      case 'processing':
        return BlockedReason.processing;
      case 'processing_failed':
        return BlockedReason.processingFailed;
      default:
        return null;
    }
  }

  String _repeatModeToString(RepeatMode repeatMode) {
    switch (repeatMode) {
      case RepeatMode.none:
        return 'none';
      case RepeatMode.one:
        return 'one';
      case RepeatMode.all:
        return 'all';
    }
  }

  RepeatMode _repeatModeFromString(String value) {
    switch (value) {
      case 'one':
        return RepeatMode.one;
      case 'all':
        return RepeatMode.all;
      default:
        return RepeatMode.none;
    }
  }
}