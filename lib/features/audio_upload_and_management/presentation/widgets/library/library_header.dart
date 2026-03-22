// Upload Feature Guide:
// Purpose: Library surface widget used by LibraryScreen.
// Used by: Referenced by nearby upload feature files.
// Concerns: Track visibility.
import 'package:flutter/material.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key, this.onOpenSettings, this.onOpenProfile});

  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Text(
                'Library',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 26,
            ),
            onPressed: onOpenSettings ?? () {},
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onOpenProfile ?? () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF9BB4E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
