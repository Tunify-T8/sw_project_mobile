import 'package:flutter/material.dart';

class EditProfileLinks extends StatelessWidget {
  final TextEditingController instagramController;
  final TextEditingController twitterController;
  final TextEditingController websiteController;
  final VoidCallback onChanged;

  const EditProfileLinks({
    super.key,
    required this.instagramController,
    required this.twitterController,
    required this.websiteController,
    required this.onChanged,
  });

  Widget buildLinkField(IconData icon, String label, TextEditingController controller) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: TextInputType.url,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Your links', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          buildLinkField(Icons.camera_alt_outlined, 'Instagram URL', instagramController),
          buildLinkField(Icons.alternate_email, 'Twitter URL', twitterController),
          buildLinkField(Icons.language, 'Website URL', websiteController),
        ],
      ),
    );
  }
}