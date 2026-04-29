// Upload Feature Guide:
// Purpose: Uploads library widget used by YourUploadsScreen.
// Used by: your_uploads_screen
// Concerns: Multi-format support; Track visibility.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/upload_item.dart';
import '../../providers/track_detail_item_provider.dart';
import '../upload_artwork_view.dart';

class YourUploadsTrackTile extends ConsumerWidget {
  const YourUploadsTrackTile({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onTap,
    required this.onMoreTap,
  });

  final UploadItem item;
  final bool isBusy;
  final ValueChanged<UploadItem> onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return GestureDetector(
      onTap: isBusy ? null : () => onTap(resolvedItem),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UploadArtworkView(
            localPath: resolvedItem.localArtworkPath,
            remoteUrl: resolvedItem.artworkUrl,
            width: 64,
            height: 64,
            backgroundColor: const Color(0xFF96B7FF),
            borderRadius: BorderRadius.circular(4),
            placeholder: const Icon(
              Icons.account_circle_rounded,
              color: Color(0xFF4872D7),
              size: 52,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resolvedItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (resolvedItem.status ==
                        UploadProcessingStatus.processing)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF333333),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PROCESSING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  resolvedItem.artistDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  resolvedItem.durationLabel,
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isBusy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            GestureDetector(
              onTap: onMoreTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.more_horiz, color: Colors.white54, size: 24),
              ),
            ),
        ],
      ),
    );
  }
}
