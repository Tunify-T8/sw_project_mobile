import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/usecases/playlist_helpers.dart';

class SecretTokenSection extends StatelessWidget {
  const SecretTokenSection({super.key, required this.playlist});

  final PlaylistEntity playlist;

  @override
  Widget build(BuildContext context) {
    final token = playlist.secretToken;
    if (playlist.privacy != CollectionPrivacy.private || token == null) {
      return const SizedBox.shrink();
    }

    final url = buildSecretTokenShareUrl(
      secretToken: token,
      baseUrl: ApiEndpoints.baseUrl,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white54, size: 16),
              SizedBox(width: 6),
              Text(
                'Secret playlist',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Anyone with this link can listen.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  url,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF1C1C1E),
                      content: Text(
                        'Secret link copied',
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Copy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
