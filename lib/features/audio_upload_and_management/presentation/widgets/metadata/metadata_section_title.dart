import 'package:flutter/material.dart';

class MetadataSectionTitle extends StatelessWidget {
  const MetadataSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFD0D0D0),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
