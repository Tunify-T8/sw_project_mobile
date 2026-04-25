import 'package:flutter/material.dart';
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
  final trimmed = _extractTrackUrl(rawLink);
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

  final token = _readPrivateToken(uri);
  return SharedTrackLink(
    trackId: trackId.trim(),
    privateToken: token == null || token.isEmpty ? null : token,
  );
}

String _extractTrackUrl(String rawLink) {
  final trimmed = rawLink.trim();
  final match = RegExp(
    r'https?://tunify\.duckdns\.org/tracks/[^\s]+',
    caseSensitive: false,
  ).firstMatch(trimmed);
  return match?.group(0) ?? trimmed;
}

String? _readPrivateToken(Uri uri) {
  for (final entry in uri.queryParameters.entries) {
    final key = entry.key.toLowerCase();
    if (key == 'privatetoken' || key == 'private_token') {
      return entry.value.trim();
    }
  }

  final rawQuery = uri.query;
  if (rawQuery.isEmpty) return null;

  for (final part in rawQuery.split('&')) {
    final index = part.indexOf('=');
    if (index <= 0) continue;
    final key = Uri.decodeQueryComponent(part.substring(0, index))
        .toLowerCase();
    if (key != 'privatetoken' && key != 'private_token') continue;
    return Uri.decodeQueryComponent(part.substring(index + 1)).trim();
  }

  return null;
}

String? _trackIdFromSegments(List<String> segments) {
  final normalized = segments.where((segment) => segment.isNotEmpty).toList();
  final tracksIndex = normalized.indexOf('tracks');
  if (tracksIndex < 0 || tracksIndex >= normalized.length - 1) return null;
  return normalized[tracksIndex + 1];
}

Future<bool> openSharedTrackLink(
  BuildContext context,
  WidgetRef ref,
  String rawLink, {
  bool replaceCurrentRoute = false,
}) async {
  final parsed = parseTrackShareLink(rawLink);
  if (parsed == null) {
    _showSnackBar(context, 'That does not look like a Tunify track link.');
    return false;
  }
  debugPrint(
    'openSharedTrackLink parsed trackId=${parsed.trackId} '
    'hasPrivateToken=${parsed.privateToken?.isNotEmpty == true}',
  );

  return openSharedTrack(
    context,
    ref,
    trackId: parsed.trackId,
    privateToken: parsed.privateToken,
    replaceCurrentRoute: replaceCurrentRoute,
  );
}

Future<bool> openSharedTrack(
  BuildContext context,
  WidgetRef ref, {
  required String trackId,
  String? privateToken,
  bool replaceCurrentRoute = false,
}) async {
  if (privateToken == null || privateToken.trim().isEmpty) {
    _showSnackBar(
      context,
      'This private link has no token. Copy the private link again.',
    );
    return false;
  }

  final notifier = ref.read(playerProvider.notifier);
  await notifier.loadTrack(
    trackId,
    privateToken: privateToken.trim(),
    autoPlay: true,
  );

  final asyncState = ref.read(playerProvider);
  if (asyncState.hasError) {
    debugPrint('openSharedTrack failed for $trackId: ${asyncState.error}');
    if (context.mounted) {
      _showSnackBar(context, _openFailureMessage(asyncState.error));
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

  if (!playerState!.canPlay) {
    if (context.mounted) {
      _showSnackBar(context, 'This link loaded, but playback is blocked.');
    }
    return false;
  }

  final item = uploadItemFromPlayerState(
    playerState,
    ref.read(globalTrackStoreProvider),
  ).copyWith(
    visibility: privateToken == null
        ? UploadVisibility.public
        : UploadVisibility.private,
    privateToken: privateToken.trim(),
  );

  if (!context.mounted) return true;
  final route = PageRouteBuilder(
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
  );
  if (replaceCurrentRoute) {
    await Navigator.of(context).pushReplacement(route);
  } else {
    await Navigator.of(context).push(route);
  }
  return true;
}

void _showSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

String _openFailureMessage(Object? error) {
  final raw = error.toString();
  if (raw.contains('private_no_token')) {
    return 'This private link is missing its token. Copy the private link again.';
  }
  if (raw.contains('Forbidden') || raw.contains('status code of 403')) {
    return 'This private link was rejected. Copy a fresh private link from the owner.';
  }

  try {
    final dynamic dynamicError = error;
    final statusCode = dynamicError.response?.statusCode;
    final data = dynamicError.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    if (statusCode == 403 && message == 'private_no_token') {
      return 'This private link is missing its token. Copy the private link again.';
    }
    if (message != null && message.isNotEmpty) {
      return 'Could not open this track: $message';
    }
  } catch (_) {}
  return 'Could not open this track.';
}
