import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/usecases/playlist_helpers.dart';

void showEmbedCodeSheet({
  required BuildContext context,
  required PlaylistEntity playlist,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _EmbedCodeSheet(playlist: playlist),
  );
}

class _EmbedCodeSheet extends StatelessWidget {
  const _EmbedCodeSheet({required this.playlist});

  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    final code = buildEmbedIframe(
      collectionId: playlist.id,
      baseUrl: ApiEndpoints.baseUrl,
    );
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Embed playlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Paste this code into your website.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text(
                'Copy code',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF1C1C1E),
                    content: Text(
                      'Embed code copied',
                      style: TextStyle(color: Colors.white),
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: bottomPadding + 16),
        ],
      ),
    );
  }
}
