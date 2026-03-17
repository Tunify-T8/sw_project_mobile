import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final double coverHeight;
  final double profileHeight;
  final String? coverUrl;
  final String? profileUrl;

  const ProfileHeader({
    super.key,
    required this.coverHeight,
    required this.profileHeight,
    this.coverUrl,
    this.profileUrl,
  });

  Widget buildCoverImage() {
    if (coverUrl != null) {
      return Container(
        width: double.infinity,
        height: coverHeight,
        color: Colors.grey.shade800,
        child: Image.network(coverUrl!, fit: BoxFit.cover),
      );
    }
    return Container(
      width: double.infinity,
      height: coverHeight,
      color: Colors.grey.shade800,
    );
  }

  Widget buildProfileImage() {
    if (profileUrl != null) {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(profileUrl!),
      );
    }
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.grey,
      child: const Icon(Icons.person, size: 50, color: Color(0xFF3A5F8A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        buildCoverImage(),
        Positioned(
          top: coverHeight - profileHeight / 2,
          left: 25,
          child: buildProfileImage(),
        ),
      ],
    );
  }
}