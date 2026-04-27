import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/api/playlist_api.dart';
import '../../data/repository/mock_playlist_repository_impl.dart';
import '../../data/repository/real_playlist_repository_impl.dart';
import '../../data/services/mock_playlist_store.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/usecases/playlist_usecases.dart';
import 'playlist_notifier.dart';
import 'playlist_state.dart';


// Flip to PlaylistBackendMode.real once the backend is ready.
enum PlaylistBackendMode { mock, real }

// const PlaylistBackendMode _activeBackend = PlaylistBackendMode.mock;
const PlaylistBackendMode _activeBackend = PlaylistBackendMode.real;

final playlistBackendModeProvider = Provider<PlaylistBackendMode>(
  (ref) => _activeBackend,
);

//  Infrastructure 

final playlistDioProvider = Provider<Dio>((ref) => ref.watch(dioProvider));

final playlistApiProvider = Provider<PlaylistApi>(
  (ref) => PlaylistApi(ref.watch(playlistDioProvider)),
);

/// Shared mock store — lives for the app lifetime so all screens share state.
final mockPlaylistStoreProvider = Provider<MockPlaylistStore>(
  (ref) => MockPlaylistStore(),
);

//  Repository

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final mode = ref.watch(playlistBackendModeProvider);
  if (mode == PlaylistBackendMode.real) {
    return RealPlaylistRepositoryImpl(ref.watch(playlistApiProvider));
  }
  return MockPlaylistRepositoryImpl(ref.watch(mockPlaylistStoreProvider));
});

//  Use cases 

final createPlaylistUseCaseProvider = Provider<CreatePlaylistUseCase>(
  (ref) => CreatePlaylistUseCase(ref.watch(playlistRepositoryProvider)),
);

final editPlaylistUseCaseProvider = Provider<EditPlaylistUseCase>(
  (ref) => EditPlaylistUseCase(ref.watch(playlistRepositoryProvider)),
);

final deletePlaylistUseCaseProvider = Provider<DeletePlaylistUseCase>(
  (ref) => DeletePlaylistUseCase(ref.watch(playlistRepositoryProvider)),
);

final getPlaylistUseCaseProvider = Provider<GetPlaylistUseCase>(
  (ref) => GetPlaylistUseCase(ref.watch(playlistRepositoryProvider)),
);

final getMyPlaylistsUseCaseProvider = Provider<GetMyPlaylistsUseCase>(
  (ref) => GetMyPlaylistsUseCase(ref.watch(playlistRepositoryProvider)),
);

final getTracksPerPlaylistUseCaseProvider = Provider<GetTracksPerPlaylistUseCase>(
  (ref) => GetTracksPerPlaylistUseCase(ref.watch(playlistRepositoryProvider)),
);

final reorderTracksUseCaseProvider = Provider<ReorderTracksUseCase>(
  (ref) => ReorderTracksUseCase(ref.watch(playlistRepositoryProvider)),
);

final addTrackUseCaseProvider = Provider<AddTrackUseCase>(
  (ref) => AddTrackUseCase(ref.watch(playlistRepositoryProvider)),
);

final removeTrackUseCaseProvider = Provider<RemoveTrackUseCase>(
  (ref) => RemoveTrackUseCase(ref.watch(playlistRepositoryProvider)),
);

// Notifier 

final playlistNotifierProvider =
    NotifierProvider<PlaylistNotifier, PlaylistState>(PlaylistNotifier.new);
