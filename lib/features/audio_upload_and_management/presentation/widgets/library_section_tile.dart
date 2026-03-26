// Upload Feature Guide:
// Purpose: Reusable library tile widget used to build upload-related menu sections.
// Used by: Referenced by nearby upload feature files.
// Concerns: Track visibility.
import 'package:flutter/material.dart';

class LibrarySectionTile extends StatelessWidget {
  const LibrarySectionTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
