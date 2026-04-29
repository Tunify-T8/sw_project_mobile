import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/upload_item.dart';
import '../screens/track_detail_screen.dart';

/// Centralised helper for building and copying track links.
///
/// Public track: `https://soundcloud.app/tracks/trackId`
/// Private track: `https://soundcloud.app/tracks/trackId?privateToken=token`
class TrackLinkHelper {
  TrackLinkHelper._();

  static const String _scheme = 'https';
  static const String _host = 'soundcloud.app';

  static Uri buildTrackLink(String trackId, {String? privateToken}) {
    final token = privateToken?.trim();
    return Uri(
      scheme: _scheme,
      host: _host,
      pathSegments: ['tracks', trackId],
      queryParameters: (token == null || token.isEmpty)
          ? null
          : {'privateToken': token},
    );
  }

  static Future<void> copyTrackLink(
    BuildContext context, {
    required String trackId,
    String? privateToken,
  }) async {
    final url = buildTrackLink(trackId, privateToken: privateToken).toString();
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Builds a minimal [UploadItem] usable by the internal player launcher
  /// when all we know about a track is its id and (optionally) its private
  /// token — e.g. when opening a private link inside the app.
  static UploadItem buildStubUploadItem(
    String trackId, {
    String? privateToken,
  }) {
    return UploadItem(
      id: trackId,
      title: 'Track',
      artistDisplay: '',
      durationLabel: '',
      durationSeconds: 0,
      artworkUrl: null,
      description: '',
      visibility: (privateToken != null && privateToken.trim().isNotEmpty)
          ? UploadVisibility.private
          : UploadVisibility.public,
      status: UploadProcessingStatus.finished,
      isExplicit: false,
      privateToken: privateToken,
      createdAt: DateTime.now(),
    );
  }

  /// Internal launch entry path — opens the track detail/player screen for a
  /// track identified only by [trackId] (and optional [privateToken] for
  /// private links).
  static Future<void> openTrackByIdAndToken(
    BuildContext context,
    WidgetRef ref,
    String trackId, {
    String? privateToken,
  }) async {
    final item = buildStubUploadItem(trackId, privateToken: privateToken);
    if (!context.mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TrackDetailScreen(item: item)));
  }

  /// External share: launch a platform-specific URL that carries the track
  /// link. Falls back to copying the link to the clipboard if the target app
  /// is not available on this device.
  static Future<void> shareExternally(
    BuildContext context, {
    required ExternalSharePlatform platform,
    required String trackId,
    String? privateToken,
    String? title,
  }) async {
    final link = buildTrackLink(trackId, privateToken: privateToken).toString();
    final text = title == null || title.trim().isEmpty
        ? link
        : '${title.trim()} — $link';

    final Uri? target = switch (platform) {
      ExternalSharePlatform.whatsapp => Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(text)}',
      ),
      ExternalSharePlatform.facebook => Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}',
      ),
      ExternalSharePlatform.instagram => null,
      ExternalSharePlatform.snapchat => null,
    };

    var opened = false;
    if (target != null) {
      try {
        opened = await launchUrl(target, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!context.mounted) return;
    if (!opened) {
      await Clipboard.setData(ClipboardData(text: link));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Link copied — paste it into ${_platformLabel(platform)} to share.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  static String _platformLabel(ExternalSharePlatform p) {
    switch (p) {
      case ExternalSharePlatform.whatsapp:
        return 'WhatsApp';
      case ExternalSharePlatform.facebook:
        return 'Facebook';
      case ExternalSharePlatform.instagram:
        return 'Instagram Stories';
      case ExternalSharePlatform.snapchat:
        return 'Snapchat';
    }
  }
}

enum ExternalSharePlatform { whatsapp, facebook, instagram, snapchat }
