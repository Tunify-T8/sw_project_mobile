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
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          decoration: buildMetadataInputDecoration('Title *'),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 28),
        const MetadataSectionTitle('Artists *'),
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
        InkWell(
          onTap: onGenreTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MetadataSectionTitle('Genre'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hasGenre
                          ? selectedGenreLabel
                          : 'Help fans discover your track',
                      style: TextStyle(
                        color: hasGenre
                            ? Colors.white
                            : const Color(0xFF666666),
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const Icon(
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
