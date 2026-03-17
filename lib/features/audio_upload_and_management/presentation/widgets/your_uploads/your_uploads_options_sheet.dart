import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';
import '../upload_artwork_view.dart';
import 'your_uploads_options_actions.dart';

Future<void> showYourUploadsOptionsSheet(
  BuildContext context, {
  required UploadItem item,
  required VoidCallback onEditTap,
  required VoidCallback onDeleteTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TrackOptionsSheet(
      item: item,
      onEditTap: onEditTap,
      onDeleteTap: onDeleteTap,
    ),
  );
}

class _TrackOptionsSheet extends StatelessWidget {
  const _TrackOptionsSheet({
    required this.item,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  final UploadItem item;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
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
                    localPath: item.localArtworkPath,
                    remoteUrl: item.artworkUrl,
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
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.artistDisplay,
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
                children: const [
                  YourUploadsShareButton(
                    icon: Icons.send_outlined,
                    label: 'Message',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.copy_outlined,
                    label: 'Copy link',
                  ),
                  YourUploadsShareButton(
                    icon: Icons.qr_code_2,
                    label: 'QR code',
                  ),
                  YourUploadsShareButton(
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
            const YourUploadsOptionRow(
              icon: Icons.queue_play_next,
              label: 'Play next',
            ),
            const YourUploadsOptionRow(
              icon: Icons.playlist_play,
              label: 'Play last',
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
