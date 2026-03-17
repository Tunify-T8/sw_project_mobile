import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library_uploads_provider.dart';
import '../../providers/library_uploads_state.dart';

Future<void> showYourUploadsFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1C1C1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _YourUploadsFilterSheet(),
  );
}

class _YourUploadsFilterSheet extends ConsumerWidget {
  const _YourUploadsFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryUploadsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              _FilterRow(
                label: 'Recently added',
                selected: state.sortOrder == UploadSortOrder.recentlyAdded,
                onTap: () => ref
                    .read(libraryUploadsProvider.notifier)
                    .setSortOrder(UploadSortOrder.recentlyAdded),
              ),
              _FilterRow(
                label: 'First added',
                selected: state.sortOrder == UploadSortOrder.firstAdded,
                onTap: () => ref
                    .read(libraryUploadsProvider.notifier)
                    .setSortOrder(UploadSortOrder.firstAdded),
              ),
              _FilterRow(
                label: 'Track name',
                selected: state.sortOrder == UploadSortOrder.trackName,
                onTap: () => ref
                    .read(libraryUploadsProvider.notifier)
                    .setSortOrder(UploadSortOrder.trackName),
              ),
              const Divider(color: Colors.white12, height: 1),
              _FilterRow(
                label: 'All',
                selected: state.visibilityFilter == UploadVisibilityFilter.all,
                onTap: () => ref
                    .read(libraryUploadsProvider.notifier)
                    .setVisibilityFilter(UploadVisibilityFilter.all),
              ),
              _FilterRow(
                label: 'Public',
                selected:
                    state.visibilityFilter == UploadVisibilityFilter.public,
                onTap: () => ref
                    .read(libraryUploadsProvider.notifier)
                    .setVisibilityFilter(UploadVisibilityFilter.public),
              ),
              _FilterRow(
                label: 'Private',
                selected:
                    state.visibilityFilter == UploadVisibilityFilter.private,
                onTap: () => ref
                    .read(libraryUploadsProvider.notifier)
                    .setVisibilityFilter(UploadVisibilityFilter.private),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.check,
        color: selected ? Colors.white : Colors.transparent,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      dense: true,
    );
  }
}
