import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls which data source the player feature uses.
///
/// Switch via --dart-define at build/run time:
///   flutter run  --dart-define=PLAYER_BACKEND=mock
///   flutter run  --dart-define=PLAYER_BACKEND=real   (default)
enum PlayerBackendMode { mock, real }

const String _playerBackendValue = String.fromEnvironment(
  'PLAYER_BACKEND',
  defaultValue: 'real',
);

final playerBackendModeProvider = Provider<PlayerBackendMode>((ref) {
  switch (_playerBackendValue.toLowerCase()) {
    case 'mock':
      return PlayerBackendMode.mock;
    case 'real':
    default:
      return PlayerBackendMode.real;
  }
});
