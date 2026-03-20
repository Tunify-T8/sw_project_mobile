import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/audio_upload_and_management/domain/entities/upload_genre.dart';

void main() {
  group('UploadGenres', () {
    test('exposes the expected preset groups', () {
      expect(UploadGenres.none.isNone, isTrue);
      expect(UploadGenres.music, isNotEmpty);
      expect(UploadGenres.audio, isNotEmpty);
      expect(UploadGenres.all.first, UploadGenres.none);
    });

    test('fromValues returns none when subgenre is blank', () {
      expect(
        UploadGenres.fromValues(category: 'music', subGenre: '   '),
        UploadGenres.none,
      );
    });

    test('fromValues returns existing presets when present', () {
      final existing = UploadGenres.music.first;
      final result = UploadGenres.fromValues(
        category: existing.categoryValue,
        subGenre: existing.subGenre,
      );

      expect(result.label, existing.label);
      expect(result.group, existing.group);
      expect(result.subGenre, existing.subGenre);
    });

    test('fromValues beautifies unknown subgenres and infers the group', () {
      final audioResult = UploadGenres.fromValues(
        category: UploadGenreGroup.audio.name,
        subGenre: 'spoken_word',
      );
      final musicResult = UploadGenres.fromValues(
        category: 'music',
        subGenre: 'alt_rock',
      );

      expect(audioResult.label, 'Spoken Word');
      expect(audioResult.group, UploadGenreGroup.audio);
      expect(musicResult.label, 'Alt Rock');
      expect(musicResult.group, UploadGenreGroup.music);
    });

    test('groupLabel returns the UI label for each group', () {
      expect(UploadGenres.groupLabel(UploadGenreGroup.music), 'Music');
      expect(UploadGenres.groupLabel(UploadGenreGroup.audio), 'Audio');
    });
  });
}
