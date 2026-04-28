import 'package:flutter/material.dart';

class PaymentResult extends StatelessWidget {
  final String responseMessage;
  final bool isSuccessful;
  const PaymentResult({super.key, required this.responseMessage, required this.isSuccessful});

  @override
  Widget build(BuildContext context) {
    const features = [
      'Ad-free listening',
      'Offline listening',
      'Expanded upload limits',
    ];
    return (isSuccessful) ? 
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(
            Icons.check_circle,
            color: Color(0xFF2ECC71),
            size: 54,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          responseMessage,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlocked features',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        for (final feature in features)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check,
                  color: Color(0xFFFF5500),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    ) : 
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Icon(
            Icons.error,
            color: Color(0xFFFF6B6B),
            size: 54,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          responseMessage,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}