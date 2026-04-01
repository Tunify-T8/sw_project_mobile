// Filter value objects used by the search repository and provider.
// These map directly to the query params in DiscoveryApi.

// ─── Track filters ────────────────────────────────────────────────────────────

enum TrackTimeAdded {
  pastHour('past_hour', 'Past hour'),
  pastDay('past_day', 'Past day'),
  pastWeek('past_week', 'Past week'),
  pastMonth('past_month', 'Past month'),
  pastYear('past_year', 'Past year'),
  allTime('all_time', 'All time');

  const TrackTimeAdded(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum TrackDuration {
  under2('lt_2', 'Under 2 min'),
  twoToTen('2_10', '2–10 min'),
  tenToThirty('10_30', '10–30 min'),
  over30('gt_30', 'Over 30 min'),
  any('any_length', 'Any length');

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

  const TrackSearchFilters({
    this.tag,
    this.timeAdded,
    this.duration,
    this.toListen,
  });

  bool get hasAny =>
      tag != null || timeAdded != null || duration != null || toListen != null;

  TrackSearchFilters copyWith({
    String? tag,
    TrackTimeAdded? timeAdded,
    TrackDuration? duration,
    TrackLicense? toListen,
    bool clearTag = false,
    bool clearTimeAdded = false,
    bool clearDuration = false,
    bool clearToListen = false,
  }) {
    return TrackSearchFilters(
      tag: clearTag ? null : tag ?? this.tag,
      timeAdded: clearTimeAdded ? null : timeAdded ?? this.timeAdded,
      duration: clearDuration ? null : duration ?? this.duration,
      toListen: clearToListen ? null : toListen ?? this.toListen,
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
  followers('followers', 'Most followed');

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
