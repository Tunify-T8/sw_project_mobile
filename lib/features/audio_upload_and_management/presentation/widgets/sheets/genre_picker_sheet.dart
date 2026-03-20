import 'package:flutter/material.dart';
import '../../../domain/entities/upload_genre.dart';

Future<void> showGenrePickerSheet(
  BuildContext context, {
  required UploadGenre selectedGenre,
  required ValueChanged<UploadGenre> onGenreSelected,
}) async {
  Widget buildSectionLabel(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
      color: const Color(0xFF2C2C2C),
      width: double.infinity,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9B9B9B),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildGenreTile(BuildContext dialogContext, UploadGenre genre) {
    final isSelected = genre.isNone
        ? selectedGenre.isNone
        : selectedGenre.categoryValue == genre.categoryValue &&
              selectedGenre.subGenre == genre.subGenre;

    return InkWell(
      onTap: () {
        onGenreSelected(genre);
        Navigator.of(dialogContext).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF444444), width: 0.7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                genre.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 86),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: const Color(0xFF222222),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.72,
            ),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                buildGenreTile(dialogContext, UploadGenres.none),
                buildSectionLabel('Music'),
                ...UploadGenres.music.map(
                  (genre) => buildGenreTile(dialogContext, genre),
                ),
                buildSectionLabel('Audio'),
                ...UploadGenres.audio.map(
                  (genre) => buildGenreTile(dialogContext, genre),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
