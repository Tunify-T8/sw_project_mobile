import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../audio_upload_and_management/data/services/global_track_store.dart';
import '../../../audio_upload_and_management/domain/entities/upload_item.dart';
import '../../../audio_upload_and_management/presentation/screens/track_detail_screen.dart';
import '../../../audio_upload_and_management/presentation/utils/playback_surface_item_mapper.dart';
import '../providers/player_provider.dart';

class SharedTrackLink {
  const SharedTrackLink({
    required this.trackId,
    this.privateToken,
  });

  final String trackId;
  final String? privateToken;
}

SharedTrackLink? parseTrackShareLink(String rawLink) {
  final trimmed = rawLink.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  final isRelativeTrackPath =
      !uri.hasScheme && _trackIdFromSegments(uri.pathSegments) != null;
  final isTunifyTrackUrl =
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.toLowerCase() == 'tunify.duckdns.org';

  if (!isRelativeTrackPath && !isTunifyTrackUrl) return null;

  final trackId = _trackIdFromSegments(uri.pathSegments);
  if (trackId == null || trackId.trim().isEmpty) return null;

  final token = uri.queryParameters['privateToken']?.trim();
  return SharedTrackLink(
    trackId: trackId.trim(),
    privateToken: token == null || token.isEmpty ? null : token,
  );
}

String? _trackIdFromSegments(List<String> segments) {
  final normalized = segments.where((segment) => segment.isNotEmpty).toList();
  final tracksIndex = normalized.indexOf('tracks');
  if (tracksIndex < 0 || tracksIndex >= normalized.length - 1) return null;
  return normalized[tracksIndex + 1];
}

Future<void> showOpenSharedTrackLinkDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
  if (!context.mounted) return;

  final controller = TextEditingController(text: clipboard?.text ?? '');
  final link = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF161616),
        title: const Text('Open shared link'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'https://tunify.duckdns.org/tracks/...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Open'),
          ),
        ],
      );
    },
  );
  controller.dispose();

  if (link == null || link.trim().isEmpty || !context.mounted) return;
  await openSharedTrackLink(context, ref, link);
}

Future<bool> openSharedTrackLink(
  BuildContext context,
  WidgetRef ref,
  String rawLink,
) async {
  final parsed = parseTrackShareLink(rawLink);
  if (parsed == null) {
    _showSnackBar(context, 'That does not look like a Tunify track link.');
    return false;
  }

  return openSharedTrack(
    context,
    ref,
    trackId: parsed.trackId,
    privateToken: parsed.privateToken,
  );
}

Future<bool> openSharedTrack(
  BuildContext context,
  WidgetRef ref, {
  required String trackId,
  String? privateToken,
}) async {
  final notifier = ref.read(playerProvider.notifier);
  await notifier.loadTrack(
    trackId,
    privateToken: privateToken,
    autoPlay: true,
  );

  final asyncState = ref.read(playerProvider);
  if (asyncState.hasError) {
    if (context.mounted) {
      _showSnackBar(context, 'Could not open this track.');
    }
    return false;
  }

  final playerState = asyncState.asData?.value;
  if (playerState?.bundle?.trackId != trackId) {
    if (context.mounted) {
      _showSnackBar(context, 'Could not load this track.');
    }
    return false;
  }

  final item = uploadItemFromPlayerState(
    playerState!,
    ref.read(globalTrackStoreProvider),
  ).copyWith(
    visibility: privateToken == null
        ? UploadVisibility.public
        : UploadVisibility.private,
    privateToken: privateToken,
  );

  if (!context.mounted) return true;
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => TrackDetailScreen(item: item),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 340),
    ),
  );
  return true;
}

void _showSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
