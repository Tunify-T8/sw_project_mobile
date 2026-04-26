import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../providers/playlist_providers.dart';

/// Opens the create / edit bottom sheet.
///
/// Pass [existing] to pre-fill in edit mode; omit it for create mode.
void showCreateEditPlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
  PlaylistSummaryEntity? existing,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CreateEditPlaylistSheet(ref: ref, existing: existing),
  );
}

class _CreateEditPlaylistSheet extends StatefulWidget {
  const _CreateEditPlaylistSheet({required this.ref, this.existing});

  final WidgetRef ref;
  final PlaylistSummaryEntity? existing;

  @override
  State<_CreateEditPlaylistSheet> createState() =>
      _CreateEditPlaylistSheetState();
}

class _CreateEditPlaylistSheetState extends State<_CreateEditPlaylistSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late CollectionPrivacy _privacy;
  final _formKey = GlobalKey<FormState>();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _descCtrl =
        TextEditingController(text: widget.existing?.description ?? '');
    _privacy = widget.existing?.privacy ?? CollectionPrivacy.public;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier =
        widget.ref.read(playlistNotifierProvider.notifier);
    if (_isEdit) {
      await notifier.editCollection(
        id: widget.existing!.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        privacy: _privacy,
      );
    } else {
      await notifier.createCollection(
        title: _titleCtrl.text.trim(),
        type: CollectionType.playlist,
        privacy: _privacy,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final state = widget.ref.watch(playlistNotifierProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEdit ? 'Edit playlist' : 'Create playlist',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _Field(
              controller: _titleCtrl,
              label: 'Title',
              hint: 'My playlist',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Optional',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _PrivacyToggle(
              value: _privacy,
              onChanged: (v) => setState(() => _privacy = v),
            ),
            const SizedBox(height: 24),
            if (state.mutationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  state.mutationError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: state.isMutating ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: state.isMutating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    )
                  : Text(
                      _isEdit ? 'Save' : 'Create',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field ────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}

// ─── Privacy toggle ──────────────────────────────────────────────────────────

class _PrivacyToggle extends StatelessWidget {
  const _PrivacyToggle({required this.value, required this.onChanged});

  final CollectionPrivacy value;
  final ValueChanged<CollectionPrivacy> onChanged;

  @override
  Widget build(BuildContext context) {
    final isPrivate = value == CollectionPrivacy.private;
    return GestureDetector(
      onTap: () => onChanged(
        isPrivate ? CollectionPrivacy.public : CollectionPrivacy.private,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(
              isPrivate ? Icons.lock_outline : Icons.public,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPrivate ? 'Private' : 'Public',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isPrivate
                        ? 'Only you can see this playlist'
                        : 'Anyone can see this playlist',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isPrivate,
              onChanged: (v) => onChanged(
                v ? CollectionPrivacy.private : CollectionPrivacy.public,
              ),
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white30,
              inactiveThumbColor: Colors.white38,
              inactiveTrackColor: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }
}
