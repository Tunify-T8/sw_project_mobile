import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/domain/entities/collection_type.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_notifier.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_providers.dart';
import 'package:software_project/features/playlists/presentation/providers/playlist_state.dart';
import 'package:software_project/features/playlists/presentation/widgets/create_edit_playlist_sheet.dart';
import 'package:software_project/features/profile/domain/entities/profile_entity.dart';
import 'package:software_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:software_project/features/profile/presentation/providers/profile_state.dart';

class _StaticPlaylistNotifier extends PlaylistNotifier {
  _StaticPlaylistNotifier(this._initialState);

  final PlaylistState _initialState;

  @override
  PlaylistState build() => _initialState;
}

class _StaticProfileNotifier extends ProfileNotifier {
  _StaticProfileNotifier(this._initialState);

  final ProfileState _initialState;

  @override
  ProfileState build() => _initialState;

  @override
  Future<void> loadProfile() async {}
}

class _AlbumCreateHost extends ConsumerWidget {
  const _AlbumCreateHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('open_album_sheet_button'),
          onPressed: () {
            showCreatePlaylistSheet(
              context: context,
              ref: ref,
              type: CollectionType.album,
            );
          },
          child: const Text('Open'),
        ),
      ),
    );
  }
}

ProfileEntity _profile({required String role}) {
  return ProfileEntity(
    id: 'user-1',
    userName: 'listener_user',
    displayName: 'Listener User',
    role: role,
    bio: '',
    city: '',
    country: '',
    userType: role,
  );
}

void main() {
  testWidgets('album create sheet shows permission message for non-artists', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playlistNotifierProvider.overrideWith(
            () => _StaticPlaylistNotifier(const PlaylistState()),
          ),
          profileProvider.overrideWith(
            () => _StaticProfileNotifier(
              ProfileState(
                status: ProfileStatus.success,
                profile: _profile(role: 'LISTENER'),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: _AlbumCreateHost()),
      ),
    );

    await tester.tap(find.byKey(const Key('open_album_sheet_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('create_album_title')), findsOneWidget);
    expect(find.byKey(const ValueKey('album_permission_message')), findsOneWidget);
    expect(find.text('Only artists can create albums'), findsOneWidget);

    final createButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('create_playlist_button')),
    );
    expect(createButton.onPressed, isNull);
  });
}
