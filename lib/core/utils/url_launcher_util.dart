import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device browser.
///
/// Shows a [SnackBar] if the URL cannot be launched.
/// All screens use this instead of calling [launchUrl] directly.
///
/// Usage:
/// ```dart
/// UrlLauncherUtil.open(context, 'https://help.soundcloud.com');
/// ```
class UrlLauncherUtil {
  UrlLauncherUtil._();

  // ── Well-known URLs used across the app ────────────────────────────────────
  static const String helpCenter = 'https://help.soundcloud.com';

  static const String termsOfUse = 'https://soundcloud.com/terms-of-use';

  static const String privacyPolicy = 'https://soundcloud.com/pages/privacy';

  // ── Launcher ───────────────────────────────────────────────────────────────

  /// Opens [url] in the external browser.
  ///
  /// Silently fails with a [SnackBar] message if the URL cannot be opened.
  static Future<void> open(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    final canOpen = await canLaunchUrl(uri);
    if (!canOpen) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link.')));
      }
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
