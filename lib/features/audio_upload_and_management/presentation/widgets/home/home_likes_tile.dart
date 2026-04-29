import 'package:flutter/material.dart';
import '../../../../engagements_social_interactions/presentation/screens/liked_tracks_screen.dart';

class HomeLikesTile extends StatelessWidget {
  const HomeLikesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LikedTracksScreen()));
        },
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3F1004), Color(0xFF2F1A14), Color(0xFF211E1D)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.favorite_border,
                color: Color(0xFFE1370F),
                size: 32,
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Text(
                  'Your likes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.shuffle),
                  color: Colors.grey,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
