// Central backend-mode switch for the messaging feature.
// Controlled at build time via `--dart-define=MESSAGING_BACKEND=mock|real`.
// Defaults to `real` now that the backend is available.
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MessagingBackendMode { mock, real }

const String _messagingBackendValue = String.fromEnvironment(
  'MESSAGING_BACKEND',
  defaultValue: 'real',
);

final messagingBackendModeProvider = Provider<MessagingBackendMode>((ref) {
  switch (_messagingBackendValue.toLowerCase()) {
    case 'mock':
      return MessagingBackendMode.mock;
    case 'real':
    default:
      return MessagingBackendMode.real;
  }
});
