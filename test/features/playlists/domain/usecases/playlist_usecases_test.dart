import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:software_project/features/playlists/domain/entities/collection_privacy.dart';
import 'package:software_project/features/playlists/domain/entities/collection_type.dart';
import 'package:software_project/features/playlists/domain/usecases/playlist_usecases.dart';

import '../../helpers/playlist_test_mocks.dart';

void main() {
  late MockPlaylistRepository repo;

  setUp(() {
    repo = MockPlaylistRepository();
  });

  group('CreatePlaylistUseCase', () {
    test('delegates to repository with required fields', () async {
      final expected = dummyPlaylist(title: 'New Mix');
      when(repo.createCollection(
        title: 'New Mix',
        type: CollectionType.playlist,
        privacy: CollectionPrivacy.public,
      )).thenAnswer((_) async => expected);

      final result = await CreatePlaylistUseCase(repo).call(
        title: 'New Mix',
        type: CollectionType.playlist,
        privacy: CollectionPrivacy.public,
      );

      expect(result.title, 'New Mix');
      expect(result.type, CollectionType.playlist);
      verify(repo.createCollection(
        title: 'New Mix',
        type: CollectionType.playlist,
        privacy: CollectionPrivacy.public,
      )).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('passes optional description to repository', () async {
      final expected = dummyPlaylist();
      when(repo.createCollection(
        title: 'With Desc',
        type: CollectionType.playlist,
        privacy: CollectionPrivacy.private,
        description: 'A great mix',
      )).thenAnswer((_) async => expected);

      await CreatePlaylistUseCase(repo).call(
        title: 'With Desc',
        type: CollectionType.playlist,
        privacy: CollectionPrivacy.private,
        description: 'A great mix',
      );

      verify(repo.createCollection(
        title: 'With Desc',
        type: CollectionType.playlist,
        privacy: CollectionPrivacy.private,
        description: 'A great mix',
      )).called(1);
    });

    test('creates album type correctly', () async {
      final expected = dummyPlaylist(type: CollectionType.album);
      when(repo.createCollection(
        title: 'My Album',
        type: CollectionType.album,
        privacy: CollectionPrivacy.public,
      )).thenAnswer((_) async => expected);

      final result = await CreatePlaylistUseCase(repo).call(
        title: 'My Album',
        type: CollectionType.album,
        privacy: CollectionPrivacy.public,
      );

      expect(result.type, CollectionType.album);
    });
  });

  group('EditPlaylistUseCase', () {
    test('delegates to repository with id and updated fields', () async {
      final expected = dummyPlaylist(title: 'Renamed');
      when(repo.updateCollection(
        id: kPlaylistId,
        title: 'Renamed',
      )).thenAnswer((_) async => expected);

      final result = await EditPlaylistUseCase(repo).call(
        id: kPlaylistId,
        title: 'Renamed',
      );

      expect(result.title, 'Renamed');
      verify(repo.updateCollection(id: kPlaylistId, title: 'Renamed'))
          .called(1);
      verifyNoMoreInteractions(repo);
    });

    test('passes privacy change to repository', () async {
      final expected = dummyPlaylist(privacy: CollectionPrivacy.private);
      when(repo.updateCollection(
        id: kPlaylistId,
        privacy: CollectionPrivacy.private,
      )).thenAnswer((_) async => expected);

      final result = await EditPlaylistUseCase(repo).call(
        id: kPlaylistId,
        privacy: CollectionPrivacy.private,
      );

      expect(result.privacy, CollectionPrivacy.private);
      verify(repo.updateCollection(
              id: kPlaylistId, privacy: CollectionPrivacy.private))
          .called(1);
    });
  });

  group('DeletePlaylistUseCase', () {
    test('delegates to repository with playlist id', () async {
      when(repo.deleteCollection(kPlaylistId))
          .thenAnswer((_) async {});

      await DeletePlaylistUseCase(repo).call(kPlaylistId);

      verify(repo.deleteCollection(kPlaylistId)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('GetPlaylistUseCase', () {
    test('returns playlist from repository by id', () async {
      final expected = dummyPlaylist(id: kPlaylistId);
      when(repo.getCollectionById(kPlaylistId))
          .thenAnswer((_) async => expected);

      final result = await GetPlaylistUseCase(repo).call(kPlaylistId);

      expect(result.id, kPlaylistId);
      verify(repo.getCollectionById(kPlaylistId)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('GetMyPlaylistsUseCase', () {
    test('delegates with default pagination', () async {
      final expected = dummyPaginatedPlaylists();
      when(repo.getMyCollections(page: 1, limit: 10))
          .thenAnswer((_) async => expected);

      final result = await GetMyPlaylistsUseCase(repo).call();

      expect(result.items.length, 1);
      verify(repo.getMyCollections(page: 1, limit: 10)).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('passes custom page and limit to repository', () async {
      final expected = dummyPaginatedPlaylists();
      when(repo.getMyCollections(page: 2, limit: 20))
          .thenAnswer((_) async => expected);

      await GetMyPlaylistsUseCase(repo).call(page: 2, limit: 20);

      verify(repo.getMyCollections(page: 2, limit: 20)).called(1);
    });

    test('passes type filter to repository', () async {
      final expected = dummyPaginatedPlaylists();
      when(repo.getMyCollections(
        page: 1,
        limit: 10,
        type: CollectionType.album,
      )).thenAnswer((_) async => expected);

      await GetMyPlaylistsUseCase(repo).call(type: CollectionType.album);

      verify(repo.getMyCollections(
        page: 1,
        limit: 10,
        type: CollectionType.album,
      )).called(1);
    });
  });

  group('GetTracksPerPlaylistUseCase', () {
    test('delegates to repository with playlistId and defaults', () async {
      final expected = dummyPaginatedTracks();
      when(repo.getCollectionTracks(
        collectionId: kPlaylistId,
        page: 1,
        limit: 50,
      )).thenAnswer((_) async => expected);

      final result = await GetTracksPerPlaylistUseCase(repo).call(
        playlistId: kPlaylistId,
      );

      expect(result.items.length, 1);
      verify(repo.getCollectionTracks(
        collectionId: kPlaylistId,
        page: 1,
        limit: 50,
      )).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('passes custom page to repository', () async {
      final expected = dummyPaginatedTracks();
      when(repo.getCollectionTracks(
        collectionId: kPlaylistId,
        page: 2,
        limit: 50,
      )).thenAnswer((_) async => expected);

      await GetTracksPerPlaylistUseCase(repo).call(
        playlistId: kPlaylistId,
        page: 2,
      );

      verify(repo.getCollectionTracks(
        collectionId: kPlaylistId,
        page: 2,
        limit: 50,
      )).called(1);
    });
  });

  group('ReorderTracksUseCase', () {
    test('delegates to repository with collectionId and ordered track ids',
        () async {
      final trackIds = ['track-1', 'track-2', 'track-3'];
      when(repo.reorderTracks(
        collectionId: kPlaylistId,
        trackIds: trackIds,
      )).thenAnswer((_) async {});

      await ReorderTracksUseCase(repo).call(
        collectionId: kPlaylistId,
        trackIds: trackIds,
      );

      verify(repo.reorderTracks(
        collectionId: kPlaylistId,
        trackIds: trackIds,
      )).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('AddTrackUseCase', () {
    test('delegates to repository with collectionId and trackId', () async {
      when(repo.addTrack(
        collectionId: kPlaylistId,
        trackId: kTrackId,
      )).thenAnswer((_) async {});

      await AddTrackUseCase(repo).call(
        collectionId: kPlaylistId,
        trackId: kTrackId,
      );

      verify(repo.addTrack(
        collectionId: kPlaylistId,
        trackId: kTrackId,
      )).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('RemoveTrackUseCase', () {
    test('delegates to repository with collectionId and trackId', () async {
      when(repo.removeTrack(
        collectionId: kPlaylistId,
        trackId: kTrackId,
      )).thenAnswer((_) async {});

      await RemoveTrackUseCase(repo).call(
        collectionId: kPlaylistId,
        trackId: kTrackId,
      );

      verify(repo.removeTrack(
        collectionId: kPlaylistId,
        trackId: kTrackId,
      )).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}
