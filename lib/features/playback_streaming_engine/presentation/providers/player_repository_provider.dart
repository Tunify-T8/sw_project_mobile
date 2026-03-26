import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/mock_player_repository_impl.dart';
import '../../data/repository/real_player_repository_impl.dart';
import '../../domain/repositories/player_repository.dart';
import 'player_backend_mode_provider.dart';
import 'player_dependencies_provider.dart';

/// Resolves the correct [PlayerRepository] based on the active backend mode.
///
/// Consumers should depend on [PlayerRepository] only — never on the
/// concrete implementation directly.
final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  final mode = ref.watch(playerBackendModeProvider);
  
  if (mode == PlayerBackendMode.real) {
    return RealPlayerRepository(ref.watch(streamingApiProvider));
  }

  return MockPlayerRepository(
    service: ref.watch(mockPlayerServiceProvider),
  );
});
