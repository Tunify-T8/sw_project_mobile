import 'package:flutter/material.dart';

class YourUploadsActionRow extends StatelessWidget {
  const YourUploadsActionRow({
    super.key,
    required this.hasItems,
    required this.isUploadBusy,
    required this.onUploadTap,
    required this.onPlayTap,
  });

  final bool hasItems;
  final bool isUploadBusy;
  final VoidCallback onUploadTap;
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: isUploadBusy ? null : onUploadTap,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isUploadBusy)
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: Colors.white,
                      ),
                    ),
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: isUploadBusy ? Colors.white54 : Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: hasItems ? () {} : null,
            icon: Icon(
              Icons.shuffle_rounded,
              color: hasItems ? Colors.white : Colors.white24,
              size: 28,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: hasItems ? onPlayTap : null,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: hasItems ? Colors.white : const Color(0xFF3A3A3A),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: hasItems ? Colors.black : Colors.white38,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
