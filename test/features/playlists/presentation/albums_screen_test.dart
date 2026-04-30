import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/domain/entities/collection_privacy.dart';
import 'package:software_project/features/playlists/domain/entities/collection_type.dart';
import 'package:software_project/features/playlists/domain/entities/playlist_summary_entity.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_notifier.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_providers.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_state.dart';
import 'package:software_project/features/playlists/presentation/screens/albums_screen.dart';
import 'package:software_project/features/profile/domain/entities/profile_entity.dart';
import 'package:software_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:software_project/features/profile/presentation/providers/profile_state.dart';

class _StaticPlaylistNotifier extends PlaylistNotifier {
  _StaticPlaylistNotifier(this._initialState);

  final PlaylistState _initialState;

  @override
  PlaylistState build() => _initialState;

  @override
  Future<void> loadMyCollections({CollectionType? type, int limit = 20}) async {}
}

class _StaticProfileNotifier extends ProfileNotifier {
  _StaticProfileNotifier(this._initialState);

  final ProfileState _initialState;

  @override
  ProfileState build() => _initialState;

  @override
  Future<void> loadProfile() async {}
}

PlaylistSummaryEntity _summary({
  required String id,
  required String title,
  required CollectionType type,
}) {
  return PlaylistSummaryEntity(
    id: id,
    title: title,
    type: type,
    privacy: CollectionPrivacy.public,
    trackCount: 3,
    likeCount: 0,
    repostsCount: 0,
    ownerFollowerCount: 0,
    isMine: true,
    isLiked: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

ProfileEntity _profile({String role = 'ARTIST'}) {
  return ProfileEntity(
    id: 'user-1',
    userName: 'artist_user',
    displayName: 'Artist User',
    role: role,
    bio: '',
    city: '',
    country: '',
    userType: role,
  );
}

void main() {
  testWidgets('albums screen exposes album keys and filters out playlists', (
    tester,
  ) async {
    final album = _summary(
      id: 'album-1',
      title: 'Debut Album',
      type: CollectionType.album,
    );
    final playlist = _summary(
      id: 'playlist-1',
      title: 'Roadtrip Playlist',
      type: CollectionType.playlist,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playlistNotifierProvider.overrideWith(
            () => _StaticPlaylistNotifier(
              PlaylistState(myCollections: [album, playlist]),
            ),
          ),
          profileProvider.overrideWith(
            () => _StaticProfileNotifier(
              ProfileState(
                status: ProfileStatus.success,
                profile: _profile(),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AlbumsScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('albums_screen')), findsOneWidget);
    expect(find.byKey(const Key('albums_add_button')), findsOneWidget);
    expect(find.byKey(const Key('albums_search_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('album_tile_album-1')), findsOneWidget);
    expect(find.text('Debut Album'), findsOneWidget);
    expect(find.text('Roadtrip Playlist'), findsNothing);
  });
}
