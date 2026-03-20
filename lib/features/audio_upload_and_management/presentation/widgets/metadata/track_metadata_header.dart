import 'package:flutter/material.dart';

import '../../providers/track_metadata_state.dart';
import '../upload_checklist_progress_ring.dart';
import 'track_metadata_tab_switcher.dart';
import 'upload_metadata_tab.dart';

class TrackMetadataHeader extends StatelessWidget {
  const TrackMetadataHeader({
    super.key,
    required this.title,
    required this.state,
    required this.selectedTab,
    required this.onCancel,
    required this.onChecklistTap,
    required this.onTabSelected,
  });

  final String title;
  final TrackMetadataState state;
  final UploadMetadataTab selectedTab;
  final VoidCallback onCancel;
  final VoidCallback onChecklistTap;
  final ValueChanged<UploadMetadataTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onChecklistTap,
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      UploadChecklistProgressRing(
                        progress: state.checklistProgress,
                        size: 42,
                        strokeWidth: 3,
                      ),
                      Text(
                        '${state.completedChecklistItems}/4',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TrackMetadataTabSwitcher(
            selectedTab: selectedTab,
            onTabSelected: onTabSelected,
          ),
        ],
      ),
    );
  }
}
