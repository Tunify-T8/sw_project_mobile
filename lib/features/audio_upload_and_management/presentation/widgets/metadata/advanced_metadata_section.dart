import 'package:flutter/material.dart';

class AdvancedMetadataSection extends StatelessWidget {
  final TextEditingController recordLabelController;
  final TextEditingController publisherController;
  final TextEditingController isrcController;
  final TextEditingController pLineController;
  final bool hasScheduledRelease;
  final String scheduledReleaseLabel;
  final bool contentWarning;
  final ValueChanged<String> onRecordLabelChanged;
  final ValueChanged<String> onPublisherChanged;
  final ValueChanged<String> onIsrcChanged;
  final ValueChanged<String> onPLineChanged;
  final ValueChanged<bool> onScheduledReleaseChanged;
  final VoidCallback onPickReleaseDate;
  final ValueChanged<bool> onContentWarningChanged;

  const AdvancedMetadataSection({
    super.key,
    required this.recordLabelController,
    required this.publisherController,
    required this.isrcController,
    required this.pLineController,
    required this.hasScheduledRelease,
    required this.scheduledReleaseLabel,
    required this.contentWarning,
    required this.onRecordLabelChanged,
    required this.onPublisherChanged,
    required this.onIsrcChanged,
    required this.onPLineChanged,
    required this.onScheduledReleaseChanged,
    required this.onPickReleaseDate,
    required this.onContentWarningChanged,
  });

  InputDecoration _inputDecoration(String label, {String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: Color(0xFFD0D0D0),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 17,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF464646), width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF7A7A7A), width: 1),
      ),
      contentPadding: const EdgeInsets.only(top: 6, bottom: 12),
      isDense: true,
    );
  }

  Widget _labelWithInfo(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.info_outline,
          size: 18,
          color: Colors.white70,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: recordLabelController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: _inputDecoration(
            'Record label',
            hintText: 'Add your record label if applicable',
          ),
          onChanged: onRecordLabelChanged,
        ),
        const SizedBox(height: 30),
        const Text(
          'Release date',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: hasScheduledRelease ? onPickReleaseDate : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF171717),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    scheduledReleaseLabel,
                    style: TextStyle(
                      color: hasScheduledRelease
                          ? const Color(0xFFD3D3D3)
                          : const Color(0xFF5B5B5B),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Switch(
              value: hasScheduledRelease,
              onChanged: onScheduledReleaseChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF4A4A4A),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF2F2F2F),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _labelWithInfo('Publisher'),
        const SizedBox(height: 8),
        TextField(
          controller: publisherController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: _inputDecoration(
            '',
            hintText: 'Add your publisher if you have one',
          ),
          onChanged: onPublisherChanged,
        ),
        const SizedBox(height: 30),
        _labelWithInfo('ISRC'),
        const SizedBox(height: 8),
        TextField(
          controller: isrcController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: _inputDecoration(
            '',
            hintText: 'e.g. USABC2312345',
          ),
          onChanged: onIsrcChanged,
        ),
        const SizedBox(height: 30),
        const Text(
          'Content warning',
          style: TextStyle(
            color: Color(0xFFD0D0D0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'E',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Contains explicit content',
                style: TextStyle(
                  color: Color(0xFFDADADA),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Switch(
              value: contentWarning,
              onChanged: onContentWarningChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF4A4A4A),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFF2F2F2F),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _labelWithInfo('P line'),
        const SizedBox(height: 8),
        TextField(
          controller: pLineController,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: _inputDecoration(
            '',
            hintText: 'e.g. 2024 [Owner Name]',
          ),
          onChanged: onPLineChanged,
        ),
      ],
    );
  }
}
