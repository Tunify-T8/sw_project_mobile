enum UploadGenreGroup {
  music,
  audio,
}

class UploadGenre {
  final String label;
  final UploadGenreGroup? group;
  final String subGenre;
  final bool isNone;

  const UploadGenre({
    required this.label,
    required this.subGenre,
    this.group,
    this.isNone = false,
  });

  String get categoryValue => group?.name ?? '';
}

class UploadGenres {
  const UploadGenres._();

  static const UploadGenre none = UploadGenre(
    label: 'None',
    subGenre: '',
    isNone: true,
  );

  static const List<UploadGenre> music = [
    UploadGenre(
      label: 'Alternative Rock',
      group: UploadGenreGroup.music,
      subGenre: 'alternative_rock',
    ),
    UploadGenre(
      label: 'Ambient',
      group: UploadGenreGroup.music,
      subGenre: 'ambient',
    ),
    UploadGenre(
      label: 'Classical',
      group: UploadGenreGroup.music,
      subGenre: 'classical',
    ),
    UploadGenre(
      label: 'Country',
      group: UploadGenreGroup.music,
      subGenre: 'country',
    ),
    UploadGenre(
      label: 'Dance & EDM',
      group: UploadGenreGroup.music,
      subGenre: 'dance_edm',
    ),
    UploadGenre(
      label: 'Dancehall',
      group: UploadGenreGroup.music,
      subGenre: 'dancehall',
    ),
    UploadGenre(
      label: 'Deep House',
      group: UploadGenreGroup.music,
      subGenre: 'deep_house',
    ),
    UploadGenre(
      label: 'Disco',
      group: UploadGenreGroup.music,
      subGenre: 'disco',
    ),
    UploadGenre(
      label: 'Drum & Bass',
      group: UploadGenreGroup.music,
      subGenre: 'drum_bass',
    ),
    UploadGenre(
      label: 'Dubstep',
      group: UploadGenreGroup.music,
      subGenre: 'dubstep',
    ),
    UploadGenre(
      label: 'Electronic',
      group: UploadGenreGroup.music,
      subGenre: 'electronic',
    ),
    UploadGenre(
      label: 'Folk & Singer-Songwriter',
      group: UploadGenreGroup.music,
      subGenre: 'folk_singer_songwriter',
    ),
    UploadGenre(
      label: 'Hip-hop & Rap',
      group: UploadGenreGroup.music,
      subGenre: 'hip_hop_rap',
    ),
    UploadGenre(
      label: 'House',
      group: UploadGenreGroup.music,
      subGenre: 'house',
    ),
    UploadGenre(
      label: 'Indie',
      group: UploadGenreGroup.music,
      subGenre: 'indie',
    ),
    UploadGenre(
      label: 'Jazz & Blues',
      group: UploadGenreGroup.music,
      subGenre: 'jazz_blues',
    ),
    UploadGenre(
      label: 'Latin',
      group: UploadGenreGroup.music,
      subGenre: 'latin',
    ),
    UploadGenre(
      label: 'Metal',
      group: UploadGenreGroup.music,
      subGenre: 'metal',
    ),
    UploadGenre(
      label: 'Piano',
      group: UploadGenreGroup.music,
      subGenre: 'piano',
    ),
    UploadGenre(
      label: 'Pop',
      group: UploadGenreGroup.music,
      subGenre: 'pop',
    ),
    UploadGenre(
      label: 'R&B & Soul',
      group: UploadGenreGroup.music,
      subGenre: 'rnb_soul',
    ),
    UploadGenre(
      label: 'Reggae',
      group: UploadGenreGroup.music,
      subGenre: 'reggae',
    ),
    UploadGenre(
      label: 'Reggaeton',
      group: UploadGenreGroup.music,
      subGenre: 'reggaeton',
    ),
    UploadGenre(
      label: 'Rock',
      group: UploadGenreGroup.music,
      subGenre: 'rock',
    ),
    UploadGenre(
      label: 'Soundtrack',
      group: UploadGenreGroup.music,
      subGenre: 'soundtrack',
    ),
    UploadGenre(
      label: 'Speech',
      group: UploadGenreGroup.music,
      subGenre: 'speech',
    ),
    UploadGenre(
      label: 'Techno',
      group: UploadGenreGroup.music,
      subGenre: 'techno',
    ),
    UploadGenre(
      label: 'Trance',
      group: UploadGenreGroup.music,
      subGenre: 'trance',
    ),
    UploadGenre(
      label: 'Trap',
      group: UploadGenreGroup.music,
      subGenre: 'trap',
    ),
    UploadGenre(
      label: 'Triphop',
      group: UploadGenreGroup.music,
      subGenre: 'triphop',
    ),
    UploadGenre(
      label: 'World',
      group: UploadGenreGroup.music,
      subGenre: 'world',
    ),
  ];

  static const List<UploadGenre> audio = [
    UploadGenre(
      label: 'Audiobooks',
      group: UploadGenreGroup.audio,
      subGenre: 'audiobooks',
    ),
    UploadGenre(
      label: 'Business',
      group: UploadGenreGroup.audio,
      subGenre: 'business',
    ),
    UploadGenre(
      label: 'Comedy',
      group: UploadGenreGroup.audio,
      subGenre: 'comedy',
    ),
    UploadGenre(
      label: 'Entertainment',
      group: UploadGenreGroup.audio,
      subGenre: 'entertainment',
    ),
    UploadGenre(
      label: 'Learning',
      group: UploadGenreGroup.audio,
      subGenre: 'learning',
    ),
    UploadGenre(
      label: 'News & Politics',
      group: UploadGenreGroup.audio,
      subGenre: 'news_politics',
    ),
    UploadGenre(
      label: 'Religion & Spirituality',
      group: UploadGenreGroup.audio,
      subGenre: 'religion_spirituality',
    ),
    UploadGenre(
      label: 'Science',
      group: UploadGenreGroup.audio,
      subGenre: 'science',
    ),
    UploadGenre(
      label: 'Sports',
      group: UploadGenreGroup.audio,
      subGenre: 'sports',
    ),
    UploadGenre(
      label: 'Storytelling',
      group: UploadGenreGroup.audio,
      subGenre: 'storytelling',
    ),
    UploadGenre(
      label: 'Technology',
      group: UploadGenreGroup.audio,
      subGenre: 'technology',
    ),
  ];

  static const List<UploadGenre> all = [
    none,
    ...music,
    ...audio,
  ];

  static UploadGenre fromValues({
    required String category,
    required String subGenre,
  }) {
    if (subGenre.trim().isEmpty) {
      return none;
    }

    for (final genre in all) {
      if (genre.categoryValue == category && genre.subGenre == subGenre) {
        return genre;
      }
    }

    return UploadGenre(
      label: _beautifySubGenre(subGenre),
      group: category == 'audio'
          ? UploadGenreGroup.audio
          : UploadGenreGroup.music,
      subGenre: subGenre,
    );
  }

  static String groupLabel(UploadGenreGroup group) {
    switch (group) {
      case UploadGenreGroup.music:
        return 'Music';
      case UploadGenreGroup.audio:
        return 'Audio';
    }
  }

  static String _beautifySubGenre(String value) {
    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
