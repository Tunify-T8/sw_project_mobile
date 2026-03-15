import 'package:flutter/material.dart';

class SaveMetadataFooter extends StatelessWidget {
  final String? errorMessage;
  final String statusText;
  final String buttonText;
  final VoidCallback? onSavePressed;

  const SaveMetadataFooter({
    super.key,
    required this.errorMessage,
    required this.statusText,
    required this.buttonText,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        SizedBox(
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              disabledBackgroundColor: const Color(0xFFBDBDBD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: onSavePressed,
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Status: $statusText',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 18),
        const Text(
          "By uploading, you confirm that your sounds comply with our Terms of Use and you don't infringe anyone else's rights.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'TERMS OF USE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}