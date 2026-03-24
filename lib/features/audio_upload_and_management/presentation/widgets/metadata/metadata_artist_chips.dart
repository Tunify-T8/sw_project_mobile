// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: track_info_form_section
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

class MetadataArtistChips extends StatelessWidget {
  const MetadataArtistChips({
    super.key,
    required this.artists,
    required this.onRemoveArtist,
  });

  final List<String> artists;
  final ValueChanged<String> onRemoveArtist;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: artists.map((artist) {
        final canRemove = artists.length > 1;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF4A4A4A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                artist.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFDADADA),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: canRemove ? () => onRemoveArtist(artist) : null,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: canRemove
                      ? const Color(0xFFBBBBBB)
                      : const Color(0xFF575757),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
