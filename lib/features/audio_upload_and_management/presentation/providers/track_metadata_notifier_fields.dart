// Upload Feature Guide:
// Purpose: Mixin of field mutation helpers used by TrackMetadataNotifier to keep metadata form updates readable.
// Used by: Watched or read by upload screens, controllers, and widgets.
// Concerns: Metadata engine.
part of 'track_metadata_provider.dart';

mixin TrackMetadataNotifierFields on Notifier<TrackMetadataState> {
  void setTitle(String value) =>
      state = state.copyWith(title: value, error: null);

  void setGenre(UploadGenre genre) {
    state = state.copyWith(
      genreCategory: genre.isNone ? '' : genre.categoryValue,
      genreSubGenre: genre.isNone ? '' : genre.subGenre,
      error: null,
    );
  }

  void setTagsText(String value) =>
      state = state.copyWith(tagsText: value, error: null);

  void setDescription(String value) =>
      state = state.copyWith(description: value, error: null);

  void setPrivacy(String value) =>
      state = state.copyWith(privacy: value, error: null);

  void addArtist(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(error: 'Enter an artist name before adding it.');
      return;
    }
    if (state.artists.any(
      (artist) => artist.toLowerCase() == trimmed.toLowerCase(),
    )) {
      state = state.copyWith(error: '$trimmed is already in the artist list.');
      return;
    }
    state = state.copyWith(artists: [...state.artists, trimmed], error: null);
  }

  void removeArtist(String artist) {
    if (state.artists.length == 1) {
      state = state.copyWith(error: 'At least one artist is required.');
      return;
    }
    state = state.copyWith(
      artists: state.artists.where((value) => value != artist).toList(),
      error: null,
    );
  }

  Future<void> pickArtwork({bool fromCamera = false}) async {
    try {
      final picker = ref.read(filePickerServiceProvider);
      final path = await picker.pickArtworkImage(fromCamera: fromCamera);
      if (path == null) return;
      state = state.copyWith(artworkPath: path, error: null);
    } catch (error, stackTrace) {
      logUploadError('pick artwork', error, stackTrace);
      state = state.copyWith(
        error: userFriendlyUploadError(
          error,
          fallback:
              'We could not use that artwork image. Please try another one.',
        ),
      );
    }
  }

  void setRecordLabel(String value) =>
      state = state.copyWith(recordLabel: value, error: null);

  void setPublisher(String value) =>
      state = state.copyWith(publisher: value, error: null);

  void setIsrc(String value) =>
      state = state.copyWith(isrc: value, error: null);

  void setPLine(String value) =>
      state = state.copyWith(pLine: value, error: null);

  void setHasScheduledRelease(bool value) {
    state = state.copyWith(
      hasScheduledRelease: value,
      scheduledReleaseDate: value
          ? (state.scheduledReleaseDate ?? DateTime.now())
          : state.scheduledReleaseDate,
      error: null,
    );
  }

  void setScheduledReleaseDate(DateTime value) {
    state = state.copyWith(
      scheduledReleaseDate: value,
      hasScheduledRelease: true,
      error: null,
    );
  }

  void setContentWarning(bool value) =>
      state = state.copyWith(contentWarning: value, error: null);

  void setAllowDownloads(bool value) =>
      state = state.copyWith(allowDownloads: value, error: null);

  void setOfflineListening(bool value) =>
      state = state.copyWith(offlineListening: value, error: null);

  void setIncludeInRss(bool value) =>
      state = state.copyWith(includeInRss: value, error: null);

  void setDisplayEmbedCode(bool value) =>
      state = state.copyWith(displayEmbedCode: value, error: null);

  void setAppPlaybackEnabled(bool value) =>
      state = state.copyWith(appPlaybackEnabled: value, error: null);

  void setAvailabilityType(String value) {
    state = state.copyWith(
      availabilityType: value,
      availabilityRegionsText: value == 'worldwide'
          ? ''
          : state.availabilityRegionsText,
      error: null,
    );
  }

  void setAvailabilityRegionsText(String value) =>
      state = state.copyWith(availabilityRegionsText: value, error: null);

  void setLicensing(String value) =>
      state = state.copyWith(licensing: value, error: null);
}
