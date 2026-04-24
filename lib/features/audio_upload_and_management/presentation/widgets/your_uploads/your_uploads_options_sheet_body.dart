// Upload Feature Guide:
// Purpose: Legacy body widget for the Your Uploads track options sheet.
// Used by: internal — the shared track_options_sheet now drives this UI.
// Concerns: Multi-format support; Track visibility.
//
// This file was originally a `part of 'your_uploads_options_sheet.dart'` body.
// The parent was refactored to delegate to the shared track options sheet, so
// this file is kept as a self-contained standalone widget that preserves the
// exact same logic (header + share row + option rows + copy/WhatsApp actions)
// in case any surface wants to mount the old, upload-specific sheet directly.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_item_provider.dart';
import '../../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../upload_artwork_view.dart';
import 'your_uploads_options_actions.dart';

class YourUploadsTrackOptionsSheet extends ConsumerWidget {
  const YourUploadsTrackOptionsSheet({
    super.key,
    required this.item,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  final UploadItem item;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  UploadArtworkView(
                    localPath: resolvedItem.localArtworkPath,
                    remoteUrl: resolvedItem.artworkUrl,
                    width: 56,
                    height: 56,
                    backgroundColor: const Color(0xFF3A4A6A),
                    borderRadius: BorderRadius.circular(4),
                    placeholder: const Icon(
                      Icons.account_circle_rounded,
                      color: Color(0xFF4872D7),
                      size: 44,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedItem.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          resolvedItem.artistDisplay,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SHARE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const YourUploadsShareButton(
                    icon: Icons.send_outlined,
                    label: 'Message',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy link',
                    onTap: () => _copyUploadShareLink(
                      context,
                      ref,
                      resolvedItem,
                    ),
                  ),
                  const YourUploadsShareButton(
                    icon: Icons.qr_code_2,
                    label: 'QR code',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    onTap: () async {
                      final url = await _buildUploadShareUrl(
                        context,
                        ref,
                        resolvedItem,
                      );
                      if (url == null) return;
                      final msg = Uri.encodeComponent(
                        'Check out "${resolvedItem.title}" on Tunify: $url',
                      );
                      await launchUrl(
                        Uri.parse('https://wa.me/?text=$msg'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                  const YourUploadsShareButton(
                    icon: Icons.sms_outlined,
                    label: 'SMS',
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const YourUploadsOptionRow(
              icon: Icons.favorite_border,
              label: 'Like',
            ),
            YourUploadsOptionRow(
              icon: Icons.edit_outlined,
              label: 'Edit track',
              onTap: onEditTap,
            ),
            const Divider(color: Colors.white12, height: 1),
            YourUploadsOptionRow(
              icon: Icons.queue_play_next,
              label: 'Play next',
              onTap: () {
                ref.read(playerProvider.notifier).addToQueueNext(resolvedItem.id);
                Navigator.pop(context);
              },
            ),
            YourUploadsOptionRow(
              icon: Icons.playlist_play,
              label: 'Play last',
              onTap: () {
                ref.read(playerProvider.notifier).addToQueueLast(resolvedItem.id);
                Navigator.pop(context);
              },
            ),
            const YourUploadsOptionRow(
              icon: Icons.playlist_add,
              label: 'Add to playlist',
            ),
            const YourUploadsOptionRow(
              icon: Icons.radio,
              label: 'Start station',
            ),
            const Divider(color: Colors.white12, height: 1),
            const YourUploadsOptionRow(
              icon: Icons.graphic_eq,
              label: 'Behind this track',
            ),
            const YourUploadsOptionRow(
              icon: Icons.comment_outlined,
              label: 'View comments',
            ),
            YourUploadsOptionRow(
              icon: Icons.delete_outline,
              label: 'Delete track',
              color: Colors.redAccent,
              onTap: onDeleteTap,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

Future<void> _copyUploadShareLink(
  BuildContext context,
  WidgetRef ref,
  UploadItem item,
) async {
  final url = await _buildUploadShareUrl(context, ref, item);
  if (url == null) return;

  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        item.visibility == UploadVisibility.private
            ? 'Private link copied to clipboard'
            : 'Link copied to clipboard',
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

Future<String?> _buildUploadShareUrl(
  BuildContext context,
  WidgetRef ref,
  UploadItem item,
) async {
  var shareItem = item;
  ref.invalidate(trackDetailItemProvider(item));
  shareItem = await ref
      .read(trackDetailItemProvider(item).future)
      .timeout(const Duration(seconds: 5), onTimeout: () => item);

  final privateToken = shareItem.privateToken?.trim();
  final shouldUsePrivateLink = item.visibility == UploadVisibility.private ||
      shareItem.visibility == UploadVisibility.private ||
      (privateToken != null && privateToken.isNotEmpty);

  if (shouldUsePrivateLink &&
      (privateToken == null || privateToken.isEmpty)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create private link. Token is missing.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return null;
  }

  return ApiEndpoints.shareTrackUrl(
    shareItem.id,
    privateToken: shouldUsePrivateLink ? privateToken : null,
  );
}
