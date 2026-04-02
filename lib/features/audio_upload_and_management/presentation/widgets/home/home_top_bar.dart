import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.isBusy,
    required this.onOpenArtistHome,
    required this.onStartUpload,
  });

  final bool isBusy;
  final VoidCallback onOpenArtistHome;
  final VoidCallback onStartUpload;

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
          const _CircleIconButton(icon: Icons.chat_bubble_outline),
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
  });

  final IconData icon;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    );
  }
}
