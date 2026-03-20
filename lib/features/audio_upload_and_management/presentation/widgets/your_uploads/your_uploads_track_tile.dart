import 'package:flutter/material.dart';

import '../../../domain/entities/upload_item.dart';
import '../upload_artwork_view.dart';

class YourUploadsTrackTile extends StatelessWidget {
  const YourUploadsTrackTile({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onTap,
    required this.onMoreTap,
  });

  final UploadItem item;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UploadArtworkView(
            localPath: item.localArtworkPath,
            remoteUrl: item.artworkUrl,
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
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.status == UploadProcessingStatus.processing)
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
                  item.artistDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  item.durationLabel,
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
