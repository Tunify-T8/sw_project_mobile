import 'package:flutter/material.dart';

class TrackInfoFormSection extends StatelessWidget {
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

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFFD0D0D0),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 17,
        fontWeight: FontWeight.w400,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF464646), width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF7A7A7A), width: 1),
      ),
      contentPadding: const EdgeInsets.only(top: 6, bottom: 12),
      isDense: true,
    );
  }

  void _submitArtist() {
    onAddArtist(artistController.text);
    artistController.clear();
  }

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
          decoration: _inputDecoration('Title *'),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 28),
        const Text(
          'Artists *',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: artists.map((artist) {
            final canRemove = artists.length > 1;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
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
        ),
        const SizedBox(height: 14),
        TextField(
          controller: artistController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
          decoration: _inputDecoration(
            '',
            hintText: 'Add any other collaborators of the track',
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: _submitArtist,
              icon: const Icon(
                Icons.add,
                color: Color(0xFF787878),
              ),
            ),
          ),
          onSubmitted: (_) => _submitArtist(),
        ),
        const SizedBox(height: 28),
        InkWell(
          onTap: onGenreTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genre',
                style: TextStyle(
                  color: Color(0xFFD0D0D0),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                        fontWeight: FontWeight.w400,
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
          decoration: _inputDecoration(
            'Description',
            hintText: 'Add any details about your track for fans',
          ),
          onChanged: onDescriptionChanged,
        ),
        const SizedBox(height: 28),
        TextField(
          controller: captionController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
          ),
          decoration: _inputDecoration(
            'Caption',
            hintText: 'Add a caption to your post (optional)',
          ),
          onChanged: onCaptionChanged,
        ),
      ],
    );
  }
}
