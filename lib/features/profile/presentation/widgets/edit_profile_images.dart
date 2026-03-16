import 'dart:io';
import 'package:flutter/material.dart';

class EditProfileImages extends StatelessWidget {
  final File? coverImage;
  final File? profileImage;
  final VoidCallback onCoverTap;
  final VoidCallback onProfileTap;

  final VoidCallback onCoverDelete;    // ← add
  final VoidCallback onProfileDelete;

  static const double coverHeight = 150;
  static const double profileHeight = 150;

  const EditProfileImages({
    super.key,
    required this.coverImage,
    required this.profileImage,
    required this.onCoverTap,
    required this.onProfileTap,
  });

  Widget buildCoverImage() {
  Widget coverContent;
  if (coverImage != null) {
    coverContent = Image.file(coverImage!, fit: BoxFit.cover);
  } else {
    coverContent = const SizedBox.shrink();
  }

  return GestureDetector(
    onTap: onCoverTap,
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          height: coverHeight,
          color: Colors.grey.shade800,
          child: coverContent,
        ),
        Positioned(
          bottom: 10,
          right: 14,
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
  );
}

Widget buildProfileImage() {
  ImageProvider? image;
  if (profileImage != null) {
    image = FileImage(profileImage!);
  }

  Widget? avatarChild;
  if (profileImage == null) {
    avatarChild = const Icon(Icons.person, size: 50, color: Color(0xFF3A5F8A));
  }

  return GestureDetector(
    onTap: onProfileTap,
    child: Stack(
      children: [
        CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.grey,
          backgroundImage: image,
          child: avatarChild,
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
          ),
        ),
      ],
    ),
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