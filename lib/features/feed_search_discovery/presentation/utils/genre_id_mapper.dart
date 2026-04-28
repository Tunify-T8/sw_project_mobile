class GenreIdMapper {
  // Primary keys — match the display labels used in GenreIdMapper lookups
  // from the feed home screen (TrendingGenreSection).
  static const Map<String, String> _byLabel = {
    'Jazz': '1ab2245e-a50c-4d1e-b8ee-a1afd48a196d',
    'Rock, Metal, Punk': '55d2eefb-6a30-4782-aa06-60ab404d4f06',
    'Soul': 'd60c837b-0531-45db-a241-d460a18d327c',
    'Pop': 'e36de581-0571-4b78-b0c9-4fa70d467d3',
    'Hip Hop & Rap': '52b04ead-052b-43b7-bf5c-438fa58beb35',
    'House': '8a1251cd-924b-4177-910e-75b09fed2b64',
    'SoundCloud': '99b82a1f-7203-47fb-8d04-c39a990ff608',
    'R&B': 'd60c837b-0531-45db-a241-d460a18d327c',
    'Folk': '3d35597e-6535-4eca-a304-870cc9427350',
    'Latin': 'ed35fe7b-0f4f-48b5-a9e3-b2059593e7b6',
    'Indie': 'd66ccd61-48da-4d85-944e-9cce177836c4',
    'Techno': '104e78d4-2204-47f6-b1e2-a16ef8da6873',
    'Country': 'ec8ab1bd-9f9c-4b10-a532-16f0b27786c0',
    'Reggae': '483b8cf2-b9b9-41bf-a61b-b4945a6ee7e3',
    'Electronic': 'f57c36fc-83d0-42aa-94f2-093e9e7f7029',
  };

  // Short-ID keys — match the id field on SearchGenreEntity and _GenreItem
  // in search_genre_grid.dart. These map to the same backend UUIDs.
  // Genres that have no backend UUID (chill, workout, party, etc.) return ''
  // which is handled gracefully — getTrending is called without genreId.
  static const Map<String, String> _byShortId = {
    'hip_hop_rap': '52b04ead-052b-43b7-bf5c-438fa58beb35',
    'pop': 'e36de581-0571-4b78-b0c9-4fa70d467d3',
    'house': '8a1251cd-924b-4177-910e-75b09fed2b64',
    'indie': 'd66ccd61-48da-4d85-944e-9cce177836c4',
    'electronic': 'f57c36fc-83d0-42aa-94f2-093e9e7f7029',
    'rnb': 'd60c837b-0531-45db-a241-d460a18d327c',
    'techno': '104e78d4-2204-47f6-b1e2-a16ef8da6873',
    'folk': '3d35597e-6535-4eca-a304-870cc9427350',
    'soul': 'd60c837b-0531-45db-a241-d460a18d327c',
    'country': 'ec8ab1bd-9f9c-4b10-a532-16f0b27786c0',
    'rock': '55d2eefb-6a30-4782-aa06-60ab404d4f06',
    'latin': 'ed35fe7b-0f4f-48b5-a9e3-b2059593e7b6',
    // No backend UUID for these — returns '' → getTrending without genreId filter
    'chill': '',
    'workout': '',
    'at_home': '',
    'study': '',
    'party': '',
    'feel_good': '',
    'healing_era': '',
  };

  /// Returns the backend UUID for a given genre label or short ID.
  /// Returns empty string if no mapping exists.
  static String getId(String genreIdOrLabel) {
    return _byShortId[genreIdOrLabel] ?? _byLabel[genreIdOrLabel] ?? '';
  }
}
