import 'package:flutter/material.dart';

import '../../domain/entities/collection_privacy.dart';

class PlaylistTitleField extends StatelessWidget {
  const PlaylistTitleField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged != null ? (_) => onChanged!() : null,
      style: const TextStyle(color: Colors.white),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Title is required' : null,
      decoration: _inputDecoration('Title', 'My playlist'),
    );
  }
}

class PlaylistDescriptionField extends StatelessWidget {
  const PlaylistDescriptionField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      onChanged: onChanged != null ? (_) => onChanged!() : null,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Description', 'Optional'),
    );
  }
}

class PlaylistPrivacyToggle extends StatelessWidget {
  const PlaylistPrivacyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

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

InputDecoration _inputDecoration(String label, String hint) => InputDecoration(
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
    );
