// Central backend-mode switch for the messaging feature.
// Controlled at build time via `--dart-define=MESSAGING_BACKEND=mock|real`.
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MessagingBackendMode { mock, real }

const String _messagingBackendValue = String.fromEnvironment(
  'MESSAGING_BACKEND',
  defaultValue: 'mock',
);

final messagingBackendModeProvider = Provider<MessagingBackendMode>((ref) {
  switch (_messagingBackendValue.toLowerCase()) {
    case 'real':
      return MessagingBackendMode.real;
    case 'mock':
    default:
      return MessagingBackendMode.mock;
  }
});
