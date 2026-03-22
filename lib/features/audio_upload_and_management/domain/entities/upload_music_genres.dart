// Upload Feature Guide:
// Purpose: Domain model used by the upload feature to keep business data independent from API shapes.
// Used by: upload_genres
// Concerns: Multi-format support; Metadata engine.
import 'upload_genre_model.dart';

const List<UploadGenre> uploadMusicGenres = [
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
  UploadGenre(label: 'Disco', group: UploadGenreGroup.music, subGenre: 'disco'),
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
  UploadGenre(label: 'House', group: UploadGenreGroup.music, subGenre: 'house'),
  UploadGenre(label: 'Indie', group: UploadGenreGroup.music, subGenre: 'indie'),
  UploadGenre(
    label: 'Jazz & Blues',
    group: UploadGenreGroup.music,
    subGenre: 'jazz_blues',
  ),
  UploadGenre(label: 'Latin', group: UploadGenreGroup.music, subGenre: 'latin'),
  UploadGenre(label: 'Metal', group: UploadGenreGroup.music, subGenre: 'metal'),
  UploadGenre(label: 'Piano', group: UploadGenreGroup.music, subGenre: 'piano'),
  UploadGenre(label: 'Pop', group: UploadGenreGroup.music, subGenre: 'pop'),
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
  UploadGenre(label: 'Rock', group: UploadGenreGroup.music, subGenre: 'rock'),
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
  UploadGenre(label: 'Trap', group: UploadGenreGroup.music, subGenre: 'trap'),
  UploadGenre(
    label: 'Triphop',
    group: UploadGenreGroup.music,
    subGenre: 'triphop',
  ),
  UploadGenre(label: 'World', group: UploadGenreGroup.music, subGenre: 'world'),
];
