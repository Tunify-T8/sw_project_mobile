import 'package:flutter/material.dart';

class ArtistToolPaywallFooter extends StatelessWidget {
  const ArtistToolPaywallFooter({super.key, this.onSubscribe});

  final VoidCallback? onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'EGP 164.99/month. ',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                TextSpan(
                  text: 'Cancel anytime. ',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                TextSpan(
                  text: 'Restrictions apply.',
                  style: TextStyle(color: Color(0xFF6AA8FF), fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onSubscribe,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Subscribe now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Maybe later',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
