import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_state.dart';

import '../helpers/playlist_test_mocks.dart';

void main() {
  group('PlaylistState', () {
    test('initial state has correct defaults', () {
      const state = PlaylistState();

      expect(state.myCollections, isEmpty);
      expect(state.isMyCollectionsLoading, isFalse);
      expect(state.myCollectionsError, isNull);
      expect(state.hasMoreMyCollections, isFalse);
      expect(state.myCollectionsPage, 1);

      expect(state.activePlaylist, isNull);
      expect(state.activeTracks, isEmpty);
      expect(state.isDetailLoading, isFalse);
      expect(state.detailError, isNull);

      expect(state.isTracksLoading, isFalse);
      expect(state.hasMoreTracks, isFalse);
      expect(state.tracksPage, 1);

      expect(state.isMutating, isFalse);
      expect(state.mutationError, isNull);
    });

    group('copyWith — preserves existing values', () {
      test('returns identical state when no overrides given', () {
        final playlist = dummyPlaylist();
        final track = dummyPlaylistTrack();
        final summary = dummyPlaylistSummary();

        final state = PlaylistState(
          myCollections: [summary],
          isMyCollectionsLoading: true,
          myCollectionsPage: 2,
          activePlaylist: playlist,
          activeTracks: [track],
          isMutating: true,
        );
        final copied = state.copyWith();

        expect(copied.myCollections, [summary]);
        expect(copied.isMyCollectionsLoading, isTrue);
        expect(copied.myCollectionsPage, 2);
        expect(copied.activePlaylist, playlist);
        expect(copied.activeTracks, [track]);
        expect(copied.isMutating, isTrue);
      });

      test('overrides only specified fields', () {
        final state = PlaylistState(
          isMyCollectionsLoading: true,
          myCollectionsPage: 3,
        );
        final updated = state.copyWith(isMyCollectionsLoading: false);

        expect(updated.isMyCollectionsLoading, isFalse);
        expect(updated.myCollectionsPage, 3);
      });
    });

    group('copyWith — myCollections', () {
      test('replaces myCollections when provided', () {
        final s1 = dummyPlaylistSummary(id: 'p-1');
        final s2 = dummyPlaylistSummary(id: 'p-2');
        final state = PlaylistState(myCollections: [s1]);
        final updated = state.copyWith(myCollections: [s2]);

        expect(updated.myCollections, [s2]);
        expect(updated.myCollections.any((s) => s.id == 'p-1'), isFalse);
      });

      test('updates myCollectionsPage', () {
        const state = PlaylistState(myCollectionsPage: 1);
        final updated = state.copyWith(myCollectionsPage: 2);

        expect(updated.myCollectionsPage, 2);
      });

      test('updates hasMoreMyCollections', () {
        const state = PlaylistState(hasMoreMyCollections: false);
        final updated = state.copyWith(hasMoreMyCollections: true);

        expect(updated.hasMoreMyCollections, isTrue);
      });
    });

    group('copyWith — clearMyCollectionsError', () {
      test('clears myCollectionsError when flag is true', () {
        final state = PlaylistState(myCollectionsError: 'failed to load');
        final updated = state.copyWith(clearMyCollectionsError: true);

        expect(updated.myCollectionsError, isNull);
      });

      test('keeps myCollectionsError when flag is false and no new value', () {
        final state = PlaylistState(myCollectionsError: 'failed to load');
        final updated = state.copyWith(isMyCollectionsLoading: false);

        expect(updated.myCollectionsError, 'failed to load');
      });

      test('replaces myCollectionsError with new value', () {
        final state = PlaylistState(myCollectionsError: 'old error');
        final updated =
            state.copyWith(myCollectionsError: 'new error');

        expect(updated.myCollectionsError, 'new error');
      });
    });

    group('copyWith — activePlaylist', () {
      test('sets activePlaylist when provided', () {
        const state = PlaylistState();
        final playlist = dummyPlaylist();
        final updated = state.copyWith(activePlaylist: playlist);

        expect(updated.activePlaylist, playlist);
      });

      test('clears activePlaylist when clearActivePlaylist is true', () {
        final state = PlaylistState(activePlaylist: dummyPlaylist());
        final updated = state.copyWith(clearActivePlaylist: true);

        expect(updated.activePlaylist, isNull);
      });

      test('preserves activePlaylist when not cleared and not overridden', () {
        final playlist = dummyPlaylist();
        final state = PlaylistState(activePlaylist: playlist);
        final updated = state.copyWith(isDetailLoading: false);

        expect(updated.activePlaylist, playlist);
      });
    });

    group('copyWith — detailError', () {
      test('clears detailError when clearDetailError is true', () {
        final state = PlaylistState(detailError: 'not found');
        final updated = state.copyWith(clearDetailError: true);

        expect(updated.detailError, isNull);
      });

      test('sets detailError when provided', () {
        const state = PlaylistState();
        final updated = state.copyWith(detailError: 'server error');

        expect(updated.detailError, 'server error');
      });
    });

    group('copyWith — tracks', () {
      test('replaces activeTracks when provided', () {
        final t1 = dummyPlaylistTrack(position: 1);
        final t2 = dummyPlaylistTrack(position: 2);
        final state = PlaylistState(activeTracks: [t1]);
        final updated = state.copyWith(activeTracks: [t1, t2]);

        expect(updated.activeTracks.length, 2);
        expect(updated.activeTracks.last.position, 2);
      });

      test('updates tracksPage', () {
        const state = PlaylistState(tracksPage: 1);
        final updated = state.copyWith(tracksPage: 2);

        expect(updated.tracksPage, 2);
      });

      test('updates hasMoreTracks', () {
        const state = PlaylistState(hasMoreTracks: false);
        final updated = state.copyWith(hasMoreTracks: true);

        expect(updated.hasMoreTracks, isTrue);
      });
    });

    group('copyWith — mutations', () {
      test('sets isMutating to true', () {
        const state = PlaylistState();
        final updated = state.copyWith(isMutating: true);

        expect(updated.isMutating, isTrue);
      });

      test('sets mutationError', () {
        const state = PlaylistState();
        final updated = state.copyWith(mutationError: 'create failed');

        expect(updated.mutationError, 'create failed');
      });

      test('clears mutationError when clearMutationError is true', () {
        final state = PlaylistState(mutationError: 'create failed');
        final updated = state.copyWith(clearMutationError: true);

        expect(updated.mutationError, isNull);
      });

      test('preserves mutationError when not cleared', () {
        final state = PlaylistState(mutationError: 'delete failed');
        final updated = state.copyWith(isMutating: false);

        expect(updated.mutationError, 'delete failed');
      });
    });
  });
}
