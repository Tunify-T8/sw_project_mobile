import 'package:flutter/material.dart';
import 'upload_metadata_tab.dart';

class TrackMetadataTabSwitcher extends StatelessWidget {
  final UploadMetadataTab selectedTab;
  final ValueChanged<UploadMetadataTab> onTabSelected;

  const TrackMetadataTabSwitcher({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF595959),
          width: 1.15,
        ),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Track Info',
            isSelected: selectedTab == UploadMetadataTab.trackInfo,
            onTap: () => onTabSelected(UploadMetadataTab.trackInfo),
          ),
          _TabButton(
            label: 'Advanced',
            isSelected: selectedTab == UploadMetadataTab.advanced,
            onTap: () => onTabSelected(UploadMetadataTab.advanced),
          ),
          _TabButton(
            label: 'Permissions',
            isSelected: selectedTab == UploadMetadataTab.permissions,
            onTap: () => onTabSelected(UploadMetadataTab.permissions),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3A3A3A) : Colors.transparent,
            borderRadius: BorderRadius.circular(27),
            border: Border.all(
              color: isSelected ? const Color(0xFF8A8A8A) : Colors.transparent,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
