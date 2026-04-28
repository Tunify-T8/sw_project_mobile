import 'package:flutter/material.dart';

class SubscriptionTestimonial extends StatelessWidget {
  const SubscriptionTestimonial({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5D0F97), Color(0xFF423BB3)],
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 200),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "“It's such a simple idea. Your monthly fees get split up between the songs you actually listen to.”",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "— RAC, musician and producer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 20,
          top: 25,
          bottom: -30,
          child: Container(
            width: 170,
            height: 200,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(
                  'https://specials-images.forbesimg.com/imageserve/6047077e9d0982ef2a4e2817/960x0.jpg',
                ),
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
