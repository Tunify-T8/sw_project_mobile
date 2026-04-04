import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits `true` when the device has at least one active network interface,
/// `false` when it has none.
///
/// Performs an immediate check on first listen so the initial value reflects
/// the real current state rather than an arbitrary default.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Emit the current state right away (async, but resolves in milliseconds).
  final initial = await connectivity.checkConnectivity();
  yield initial.any((r) => r != ConnectivityResult.none);

  // Emit every subsequent change.
  await for (final results in connectivity.onConnectivityChanged) {
    yield results.any((r) => r != ConnectivityResult.none);
  }
});

/// Synchronous point-in-time view of network availability.
///
/// Defaults to `true` (optimistic / assume online) until the first async
/// check resolves — this way the app never incorrectly blocks a network call
/// on the very first interaction.
///
/// Use [connectivityProvider] when you need to react to changes.
/// Use this provider when you need a quick inline check inside an async
/// function (e.g. "should I skip the server call right now?").
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).maybeWhen(
    data: (online) => online,
    orElse: () => true,
  );
});
