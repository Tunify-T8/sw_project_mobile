import 'package:flutter/material.dart';
import '../../providers/track_metadata_state.dart';
import '../upload_checklist_progress_ring.dart';

Future<void> showTrackChecklistSheet(
  BuildContext context,
  TrackMetadataState state,
) async {
  final completed = state.completedChecklistItems;

  Widget checklistItem({
    required String label,
    required String tip,
    required bool done,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? const Color(0xFFA855F7) : Colors.white70,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
              const SizedBox(height: 2),
              Text(
                tip,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF242424),
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.74,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Get everything in place',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Fans are more likely to play your track when you complete these:',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              UploadChecklistProgressRing(
                                progress: state.checklistProgress,
                                size: 92,
                                strokeWidth: 8,
                              ),
                              Text(
                                '$completed/4',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              checklistItem(
                                label: 'Title',
                                tip: "Tip: don't include artist name",
                                done: state.hasTitle,
                              ),
                              const SizedBox(height: 16),
                              checklistItem(
                                label: 'Artwork',
                                tip: 'Add cover art for better presentation',
                                done: state.hasArtwork,
                              ),
                              const SizedBox(height: 16),
                              checklistItem(
                                label: 'Genre',
                                tip: 'Help fans discover your track',
                                done: state.hasGenre,
                              ),
                              const SizedBox(height: 16),
                              checklistItem(
                                label: 'Description',
                                tip:
                                    'Add any details about your track for fans',
                                done: state.hasDescription,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Ok, got it',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
