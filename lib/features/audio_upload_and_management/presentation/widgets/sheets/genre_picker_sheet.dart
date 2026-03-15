import 'package:flutter/material.dart';
import '../../../domain/entities/upload_genre_model.dart';
//import '../../../domain/entities/upload_genres.dart';


Future<void> showGenrePickerSheet(
  BuildContext context, {
  required UploadGenre selectedGenre,
  required ValueChanged<UploadGenre> onGenreSelected,
}) async {
  Widget buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildGenreTile(UploadGenre genre) {
    final isSelected = genre.isNone
        ? selectedGenre.isNone
        : selectedGenre.categoryValue == genre.categoryValue &&
            selectedGenre.subGenre == genre.subGenre;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        genre.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check,
              color: Colors.white,
            )
          : null,
      onTap: () {
        onGenreSelected(genre);
        Navigator.pop(context);
      },
    );
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1C1C1E),
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.82,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    buildGenreTile(UploadGenres.none),
                    buildSectionLabel('Music'),
                    ...UploadGenres.music.map(buildGenreTile),
                    buildSectionLabel('Audio'),
                    ...UploadGenres.audio.map(buildGenreTile),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}