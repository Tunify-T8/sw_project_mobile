import 'package:flutter/material.dart';

class HomeUploadActionButton extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onTap;

  const HomeUploadActionButton({
    super.key,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
              ),
            ),
            if (isBusy)
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
