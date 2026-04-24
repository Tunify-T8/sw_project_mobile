// Upload Feature Guide:
// Purpose: Metadata form widget used inside TrackMetadataScreen and TrackMetadataBody.
// Used by: track_metadata_body
// Concerns: Metadata engine.
import 'package:flutter/material.dart';

import 'metadata_artist_chips.dart';
import 'metadata_input_decoration.dart';
import 'metadata_section_title.dart';

class TrackInfoFormSection extends StatelessWidget {
  const TrackInfoFormSection({
    super.key,
    required this.titleController,
    required this.artistController,
    required this.descriptionController,
    required this.captionController,
    required this.artists,
    required this.hasGenre,
    required this.selectedGenreLabel,
    required this.onTitleChanged,
    required this.onAddArtist,
    required this.onRemoveArtist,
    required this.onGenreTap,
    required this.onDescriptionChanged,
    required this.onCaptionChanged,
  });

  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController descriptionController;
  final TextEditingController captionController;
  final List<String> artists;
  final bool hasGenre;
  final String selectedGenreLabel;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onAddArtist;
  final ValueChanged<String> onRemoveArtist;
  final VoidCallback onGenreTap;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onCaptionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          decoration: buildMetadataInputDecoration(
            'Title',
            requiredField: true,
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 28),
        const MetadataSectionTitle('Artists', requiredField: true),
        const SizedBox(height: 14),
        MetadataArtistChips(artists: artists, onRemoveArtist: onRemoveArtist),
        const SizedBox(height: 14),
        TextField(
          controller: artistController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration:
              buildMetadataInputDecoration(
                '',
                hintText: 'Add any other collaborators of the track',
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () {
                    onAddArtist(artistController.text);
                    artistController.clear();
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF787878)),
                ),
              ),
          onSubmitted: (_) {
            onAddArtist(artistController.text);
            artistController.clear();
          },
        ),
        const SizedBox(height: 28),
        const MetadataSectionTitle('Genre'),
        const SizedBox(height: 14),
        if (hasGenre)
          _GenreChip(
            label: selectedGenreLabel,
            onTap: onGenreTap,
          )
        else
          InkWell(
            onTap: onGenreTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Help fans discover your track',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.unfold_more,
                      color: Color(0xFF7C7C7C),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: const Color(0xFF464646)),
              ],
            ),
          ),
        const SizedBox(height: 28),
        TextField(
          controller: descriptionController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: buildMetadataInputDecoration(
            'Description',
            hintText: 'Add any details about your track for fans',
          ),
          onChanged: onDescriptionChanged,
        ),
        const SizedBox(height: 28),
        TextField(
          controller: captionController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: buildMetadataInputDecoration(
            'Caption',
            hintText: 'Add a caption to your post (optional)',
          ),
          onChanged: onCaptionChanged,
        ),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
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
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFDADADA),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.unfold_more,
                size: 18,
                color: Color(0xFFBBBBBB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
