import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../providers/playlist_providers.dart';
import 'playlist_form_fields.dart';

void showCreatePlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CreatePlaylistSheet(ref: ref),
  );
}

class _CreatePlaylistSheet extends StatefulWidget {
  const _CreatePlaylistSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<_CreatePlaylistSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  var _privacy = CollectionPrivacy.public;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.ref.read(playlistNotifierProvider.notifier).createCollection(
          title: _titleCtrl.text.trim(),
          type: CollectionType.playlist,
          privacy: _privacy,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isMutating = widget.ref.watch(
      playlistNotifierProvider.select((s) => s.isMutating),
    );
    final error = widget.ref.watch(
      playlistNotifierProvider.select((s) => s.mutationError),
    );

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
            const Text(
              'Create playlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            PlaylistTitleField(controller: _titleCtrl),
            const SizedBox(height: 12),
            PlaylistDescriptionField(controller: _descCtrl),
            const SizedBox(height: 20),
            PlaylistPrivacyToggle(
              value: _privacy,
              onChanged: (v) => setState(() => _privacy = v),
            ),
            const SizedBox(height: 24),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  error,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: isMutating ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isMutating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black54,
                      ),
                    )
                  : const Text(
                      'Create',
                      style: TextStyle(
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
