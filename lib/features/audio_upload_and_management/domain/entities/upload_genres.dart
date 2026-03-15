import 'upload_audio_genres.dart';
import 'upload_genre_model.dart';
import 'upload_music_genres.dart';

class UploadGenres {
  const UploadGenres._();

  static const UploadGenre none = UploadGenre(
    label: 'None',
    subGenre: '',
    isNone: true,
  );

  static List<UploadGenre> get music => uploadMusicGenres;

  static List<UploadGenre> get audio => uploadAudioGenres;

  static List<UploadGenre> get all => [
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
      group: category == UploadGenreGroup.audio.name
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