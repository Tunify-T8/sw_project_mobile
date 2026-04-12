import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.isBusy,
    required this.onOpenArtistHome,
    required this.onStartUpload,
    this.onOpenMessaging,
    this.hasUnreadMessages = false,
  });

  final bool isBusy;
  final bool hasUnreadMessages;
  final VoidCallback onOpenArtistHome;
  final VoidCallback onStartUpload;
  final VoidCallback? onOpenMessaging;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onOpenArtistHome,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF171717),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.graphic_eq, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Artist Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _CircleIconButton(
            icon: Icons.cloud_upload_outlined,
            isBusy: isBusy,
            onTap: isBusy ? null : onStartUpload,
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: onOpenMessaging,
            showUnreadDot: hasUnreadMessages,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.isBusy = false,
    this.onTap,
    this.showUnreadDot = false,
  });

  final IconData icon;
  final bool isBusy;
  final bool showUnreadDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          if (showUnreadDot)
            Positioned(
              right: 1,
              top: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5500),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF171717),
                    width: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}