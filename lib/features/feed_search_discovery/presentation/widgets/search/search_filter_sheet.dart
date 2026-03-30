// lib/features/feed_search_discovery/presentation/widgets/search/search_filter_sheet.dart
// Fixed: activeColor → activeThumbColor (deprecated after Flutter 3.31)

import 'package:flutter/material.dart';
import '../../../domain/entities/search_filters_entity.dart';

class TrackFilterSheet extends StatefulWidget {
  const TrackFilterSheet({super.key, required this.current});
  final TrackSearchFilters current;

  static Future<TrackSearchFilters?> show(
    BuildContext context,
    TrackSearchFilters current,
  ) {
    return showModalBottomSheet<TrackSearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TrackFilterSheet(current: current),
    );
  }

  @override
  State<TrackFilterSheet> createState() => _TrackFilterSheetState();
}

class _TrackFilterSheetState extends State<TrackFilterSheet> {
  late TrackSearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            _SheetHeader(
              title: 'Filter Tracks',
              onClearAll: () => setState(() => _filters = _filters.cleared()),
            ),
            const SizedBox(height: 16),
            _FilterSection(
              label: 'Date added',
              child: _ChipGroup<TrackTimeAdded>(
                options: TrackTimeAdded.values,
                selected: _filters.timeAdded,
                labelOf: (v) => v.label,
                onSelected: (v) => setState(
                  () => _filters = _filters.copyWith(
                    timeAdded: v,
                    clearTimeAdded: v == _filters.timeAdded,
                  ),
                ),
              ),
            ),
            _FilterSection(
              label: 'Duration',
              child: _ChipGroup<TrackDuration>(
                options: TrackDuration.values,
                selected: _filters.duration,
                labelOf: (v) => v.label,
                onSelected: (v) => setState(
                  () => _filters = _filters.copyWith(
                    duration: v,
                    clearDuration: v == _filters.duration,
                  ),
                ),
              ),
            ),
            _FilterSection(
              label: 'License',
              child: _ChipGroup<TrackLicense>(
                options: TrackLicense.values,
                selected: _filters.toListen,
                labelOf: (v) => v.label,
                onSelected: (v) => setState(
                  () => _filters = _filters.copyWith(
                    toListen: v,
                    clearToListen: v == _filters.toListen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ApplyButton(onTap: () => Navigator.of(context).pop(_filters)),
          ],
        ),
      ),
    );
  }
}

class CollectionFilterSheet extends StatefulWidget {
  const CollectionFilterSheet({super.key, required this.current});
  final CollectionSearchFilters current;

  static Future<CollectionSearchFilters?> show(
    BuildContext context,
    CollectionSearchFilters current,
  ) {
    return showModalBottomSheet<CollectionSearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CollectionFilterSheet(current: current),
    );
  }

  @override
  State<CollectionFilterSheet> createState() => _CollectionFilterSheetState();
}

class _CollectionFilterSheetState extends State<CollectionFilterSheet> {
  late CollectionSearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            _SheetHeader(
              title: 'Filter Collections',
              onClearAll: () => setState(() => _filters = _filters.cleared()),
            ),
            const SizedBox(height: 16),
            _FilterSection(
              label: 'Type',
              child: _ChipGroup<CollectionFilterType>(
                options: CollectionFilterType.values,
                selected: _filters.type,
                labelOf: (v) => v.label,
                onSelected: (v) => setState(
                  () => _filters = _filters.copyWith(
                    type: v,
                    clearType: v == _filters.type,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _ApplyButton(onTap: () => Navigator.of(context).pop(_filters)),
          ],
        ),
      ),
    );
  }
}

class PeopleFilterSheet extends StatefulWidget {
  const PeopleFilterSheet({super.key, required this.current});
  final PeopleSearchFilters current;

  static Future<PeopleSearchFilters?> show(
    BuildContext context,
    PeopleSearchFilters current,
  ) {
    return showModalBottomSheet<PeopleSearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PeopleFilterSheet(current: current),
    );
  }

  @override
  State<PeopleFilterSheet> createState() => _PeopleFilterSheetState();
}

class _PeopleFilterSheetState extends State<PeopleFilterSheet> {
  late PeopleSearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            _SheetHeader(
              title: 'Filter People',
              onClearAll: () => setState(() => _filters = _filters.cleared()),
            ),
            const SizedBox(height: 16),
            _FilterSection(
              label: 'Sort by',
              child: _ChipGroup<PeopleSort>(
                options: PeopleSort.values,
                selected: _filters.sort,
                labelOf: (v) => v.label,
                onSelected: (v) =>
                    setState(() => _filters = _filters.copyWith(sort: v)),
              ),
            ),
            _FilterSection(
              label: 'Verified only',
              child: Row(
                children: [
                  Switch(
                    value: _filters.verifiedOnly ?? false,
                    onChanged: (v) => setState(
                      () => _filters = _filters.copyWith(
                        verifiedOnly: v,
                        clearVerifiedOnly: !v,
                      ),
                    ),
                    // Fixed: activeColor deprecated after Flutter 3.31
                    activeThumbColor: Colors.black,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white12,
                    inactiveThumbColor: Colors.white38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (_filters.verifiedOnly ?? false) ? 'On' : 'Off',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ApplyButton(onTap: () => Navigator.of(context).pop(_filters)),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClearAll});
  final String title;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onClearAll,
          child: const Text(
            'Clear all',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }
}

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Apply',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        child,
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ChipGroup<T> extends StatelessWidget {
  const _ChipGroup({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white30,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelOf(option),
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
