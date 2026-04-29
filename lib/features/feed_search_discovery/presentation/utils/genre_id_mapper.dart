class GenreIdMapper {
  static const Map<String, String> _byLabel = {
    'Jazz': '',
    'Ambient': '1474b9a9-60ff-44ce-9af2-4205c6ae36aa',
    'Rock, Metal, Punk': 'b1ef24ad-24b3-4f9a-a56e-355409b1fdec',
    'Soul': 'abf4ab62-e8e9-4360-bc10-8ae4e6c6239a',
    'Pop': '3b4aa26f-2def-4e4d-8629-e0007c9da02d',
    'Hip Hop & Rap': 'd606420e-e214-448e-8801-017da0b4fbd3',
    'House': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'Classical': '31a75bce-49f7-4c4e-9c72-96416d8eec06',
    'Dance & EDM': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'Dancehall': 'd496ab34-4c74-443b-9eb0-3484696bc2a8',
    'SoundCloud': '',
    'R&B': 'ac9a0a15-5ad6-4ba1-b36b-28e063b2c3c2',
    'Folk': '7ce713ba-6e12-4ca7-abe1-97510c81bdff',
    'Latin': 'acd7a6a1-a465-4f07-94c9-cd0248092065',
    'Indie': '0efb127a-3dd6-4cec-83d8-7e209e1bb851',
    'Techno': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'Country': '62131a16-16fd-4586-b501-f098a772ef34',
    'Reggae': '',
    'Electronic': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
  };

  static const Map<String, String> _byShortId = {
    'hip_hop_rap': 'd606420e-e214-448e-8801-017da0b4fbd3',
    'pop': '3b4aa26f-2def-4e4d-8629-e0007c9da02d',
    'house': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'indie': '0efb127a-3dd6-4cec-83d8-7e209e1bb851',
    'electronic': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'rnb': 'ac9a0a15-5ad6-4ba1-b36b-28e063b2c3c2',
    'techno': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'folk': '7ce713ba-6e12-4ca7-abe1-97510c81bdff',
    'soul': 'abf4ab62-e8e9-4360-bc10-8ae4e6c6239a',
    'country': '62131a16-16fd-4586-b501-f098a772ef34',
    'rock': 'b1ef24ad-24b3-4f9a-a56e-355409b1fdec',
    'latin': 'acd7a6a1-a465-4f07-94c9-cd0248092065',
    'ambient': '1474b9a9-60ff-44ce-9af2-4205c6ae36aa',
    'classical': '31a75bce-49f7-4c4e-9c72-96416d8eec06',
    'dance_edm': 'f28ddd17-08e0-4b1b-a8d7-6af40c40609b',
    'dancehall': 'd496ab34-4c74-443b-9eb0-3484696bc2a8',
    'chill': '1474b9a9-60ff-44ce-9af2-4205c6ae36aa',
    'workout': '',
    'at_home': '',
    'study': '',
    'party': '',
    'feel_good': '',
    'healing_era': '',
  };

  static String getId(String genreIdOrLabel) {
    return _byShortId[genreIdOrLabel] ?? _byLabel[genreIdOrLabel] ?? '';
  }
}
