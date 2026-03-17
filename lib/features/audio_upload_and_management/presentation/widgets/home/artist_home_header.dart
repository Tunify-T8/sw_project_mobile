import 'package:flutter/material.dart';
import 'home_upload_button.dart';

class ArtistHomeHeader extends StatelessWidget {
  final bool isUploadBusy;
  final VoidCallback onUploadTap;

  const ArtistHomeHeader({
    super.key,
    required this.isUploadBusy,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.graphic_eq, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Artist Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        HomeUploadButton(isBusy: isUploadBusy, onTap: onUploadTap),
      ],
    );
  }
}
