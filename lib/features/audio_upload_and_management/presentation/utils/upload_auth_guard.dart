// Upload Feature Guide:
// Purpose: UI utility/helper used by upload screens or widgets.
// Used by: upload_flow_controller, upload_entry_screen
// Concerns: Multi-format support.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:software_project/app/router.dart';
import 'package:software_project/features/auth/presentation/providers/auth_provider.dart';

Future<bool> ensureUploadAuthenticated(
  BuildContext context,
  WidgetRef ref,
) async {
  final authState = ref.read(authControllerProvider);
  final user = authState.asData?.value;

  if (user != null && user.id.isNotEmpty) {
    return true;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Sign in to upload tracks.')));

  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.signInOrCreate,
    (route) => false,
    arguments: {'mode': 'login'},
  );

  return false;
}
