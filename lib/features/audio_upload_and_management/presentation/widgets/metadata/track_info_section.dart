import 'package:flutter/material.dart';

class TrackInfoFormSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController artistController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final List<String> artists;
  final bool hasGenre;
  final String selectedGenreLabel;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onAddArtist;
  final ValueChanged<String> onRemoveArtist;
  final VoidCallback onGenreTap;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onTagsChanged;

  const TrackInfoFormSection({
    super.key,
    required this.titleController,
    required this.artistController,
    required this.descriptionController,
    required this.tagsController,
    required this.artists,
    required this.hasGenre,
    required this.selectedGenreLabel,
    required this.onTitleChanged,
    required this.onAddArtist,
    required this.onRemoveArtist,
    required this.onGenreTap,
    required this.onDescriptionChanged,
    required this.onTagsChanged,
  });

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
      ),
    );
  }

  void _submitArtist() {
    onAddArtist(artistController.text);
    artistController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: _inputDecoration('Title *'),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 22),
          const Text(
            'Artists *',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: artists.map((artist) {
              final canRemove = artists.length > 1;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      artist.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: canRemove ? () => onRemoveArtist(artist) : null,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: canRemove ? Colors.white70 : Colors.white24,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: artistController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              '',
              hintText: 'Add any other collaborators of the track',
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: _submitArtist,
                icon: const Icon(Icons.add, color: Colors.white70),
              ),
            ),
            onSubmitted: (_) => _submitArtist(),
          ),
          const SizedBox(height: 22),
          InkWell(
            onTap: onGenreTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Genre',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
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
                          color: hasGenre ? Colors.white : Colors.white38,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.unfold_more,
                      color: Colors.white70,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: Colors.white24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: descriptionController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            maxLines: 3,
            decoration: _inputDecoration(
              'Description',
              hintText: 'Add any details about your track for fans',
            ),
            onChanged: onDescriptionChanged,
          ),
          const SizedBox(height: 22),
          TextField(
            controller: tagsController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: _inputDecoration(
              'Tags',
              hintText: 'Add comma separated tags',
            ),
            onChanged: onTagsChanged,
          ),
        ],
      ),
    );
  }
}
