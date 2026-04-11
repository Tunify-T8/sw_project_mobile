// Filter value objects used by the search repository and provider.
// These map directly to the query params in DiscoveryApi.

// ─── Track filters ────────────────────────────────────────────────────────────

enum TrackTimeAdded {
  pastHour('PAST_HOUR', 'Past hour'),
  pastDay('PAST_DAY', 'Past day'),
  pastWeek('PAST_WEEK', 'Past week'),
  pastMonth('PAST_MONTH', 'Past month'),
  pastYear('PAST_YEAR', 'Past year'),
  allTime('ALL_TIME', 'All time');

  const TrackTimeAdded(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum TrackDuration {
  under2('LT_2', 'Under 2 min'),
  twoToTen('TWO_TEN', '2–10 min'),
  tenToThirty('TEN_THIRTY', '10–30 min'),
  over30('GT_30', 'Over 30 min'),
  any('ANY', 'Any length');

  const TrackDuration(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum TrackLicense {
  streamable('streamable', 'Streamable'),
  shareable('shareable', 'Shareable'),
  modifyCommercially('modify_commercially', 'Modify commercially'),
  useCommercially('use_commercially', 'Use commercially');

  const TrackLicense(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class TrackSearchFilters {
  final String? tag;
  final TrackTimeAdded? timeAdded;
  final TrackDuration? duration;
  final TrackLicense? toListen;
  final bool? allowDownloads; // ← new: maps to allowDownloads query param

  const TrackSearchFilters({
    this.tag,
    this.timeAdded,
    this.duration,
    this.toListen,
    this.allowDownloads,
  });

  bool get hasAny =>
      tag != null ||
      timeAdded != null ||
      duration != null ||
      toListen != null ||
      allowDownloads != null;

  TrackSearchFilters copyWith({
    String? tag,
    TrackTimeAdded? timeAdded,
    TrackDuration? duration,
    TrackLicense? toListen,
    bool? allowDownloads,
    bool clearTag = false,
    bool clearTimeAdded = false,
    bool clearDuration = false,
    bool clearToListen = false,
    bool clearAllowDownloads = false,
  }) {
    return TrackSearchFilters(
      tag: clearTag ? null : tag ?? this.tag,
      timeAdded: clearTimeAdded ? null : timeAdded ?? this.timeAdded,
      duration: clearDuration ? null : duration ?? this.duration,
      toListen: clearToListen ? null : toListen ?? this.toListen,
      allowDownloads: clearAllowDownloads
          ? null
          : allowDownloads ?? this.allowDownloads,
    );
  }

  TrackSearchFilters cleared() => const TrackSearchFilters();
}

// ─── Collection filters ───────────────────────────────────────────────────────

enum CollectionFilterType {
  album('album', 'Albums'),
  playlist('playlist', 'Playlists');

  const CollectionFilterType(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class CollectionSearchFilters {
  final CollectionFilterType? type;
  final String? tag;

  const CollectionSearchFilters({this.type, this.tag});

  bool get hasAny => type != null || tag != null;

  CollectionSearchFilters copyWith({
    CollectionFilterType? type,
    String? tag,
    bool clearType = false,
    bool clearTag = false,
  }) {
    return CollectionSearchFilters(
      type: clearType ? null : type ?? this.type,
      tag: clearTag ? null : tag ?? this.tag,
    );
  }

  CollectionSearchFilters cleared() => const CollectionSearchFilters();
}

// ─── People filters ───────────────────────────────────────────────────────────

enum PeopleSort {
  relevance('relevance', 'Relevance'),
  followers('FOLLOWERS', 'Most followed');

  const PeopleSort(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class PeopleSearchFilters {
  final String? location;
  final int? minFollowers;
  final bool? verifiedOnly;
  final PeopleSort sort;

  const PeopleSearchFilters({
    this.location,
    this.minFollowers,
    this.verifiedOnly,
    this.sort = PeopleSort.relevance,
  });

  bool get hasAny =>
      location != null ||
      minFollowers != null ||
      verifiedOnly != null ||
      sort != PeopleSort.relevance;

  PeopleSearchFilters copyWith({
    String? location,
    int? minFollowers,
    bool? verifiedOnly,
    PeopleSort? sort,
    bool clearLocation = false,
    bool clearMinFollowers = false,
    bool clearVerifiedOnly = false,
  }) {
    return PeopleSearchFilters(
      location: clearLocation ? null : location ?? this.location,
      minFollowers: clearMinFollowers
          ? null
          : minFollowers ?? this.minFollowers,
      verifiedOnly: clearVerifiedOnly
          ? null
          : verifiedOnly ?? this.verifiedOnly,
      sort: sort ?? this.sort,
    );
  }

  PeopleSearchFilters cleared() => const PeopleSearchFilters();
}
