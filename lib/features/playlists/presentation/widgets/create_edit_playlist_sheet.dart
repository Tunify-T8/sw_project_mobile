import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/collection_type.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_providers.dart';
import 'playlist_form_fields.dart';

Future<PlaylistEntity?> showCreatePlaylistSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  return showModalBottomSheet<PlaylistEntity>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CreatePlaylistSheet(
      ref: ref,
      hostContext: context,
    ),
  );
}

class _CreatePlaylistSheet extends StatefulWidget {
  const _CreatePlaylistSheet({
    required this.ref,
    required this.hostContext,
  });

  final WidgetRef ref;
  final BuildContext hostContext;

  @override
  State<_CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<_CreatePlaylistSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  var _privacy = CollectionPrivacy.public;
  final _formKey = GlobalKey<FormState>();
  String? _lastShownError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final created = await widget.ref
        .read(playlistNotifierProvider.notifier)
        .createCollection(
          title: _titleCtrl.text.trim(),
          type: CollectionType.playlist,
          privacy: _privacy,
          description:
              _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        );
    if (mounted && created != null) {
      Navigator.pop(context, created);
    }
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

    if (error == null && _lastShownError != null) {
      _lastShownError = null;
    }

    if (error != null && error != _lastShownError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(widget.hostContext)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: const Color(0xFF2A2A2A),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              duration: const Duration(seconds: 3),
            ),
          );
        _lastShownError = error;
      });
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 24),
      child: SingleChildScrollView(
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
              ElevatedButton(
                onPressed: isMutating ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A2A2A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF232323),
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
                          color: Colors.white70,
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
      ),
    );
  }
}
