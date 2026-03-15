import 'package:flutter/material.dart';

class UploadPromoBanner extends StatelessWidget {
  const UploadPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF7C3AED),
            child: Icon(Icons.flash_on, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Amplify your track with Artist Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}