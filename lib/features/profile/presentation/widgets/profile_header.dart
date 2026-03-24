import 'dart:io';

import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final double coverHeight;
  final double profileHeight;
  final String? coverUrl;
  final String? profileUrl;
  //final bool isCertified;

  const ProfileHeader({
    super.key,
    required this.coverHeight,
    required this.profileHeight,
    this.coverUrl,
    this.profileUrl,
    //this.isCertified = false,
  });

  bool _isRemotePath(String? value) =>
      value != null && value.trim().startsWith('http');

  bool _isLocalPath(String? value) =>
      value != null && value.trim().isNotEmpty && File(value).existsSync();

  Widget buildCoverImage() {
    if (_isLocalPath(coverUrl)) {
      return Container(
        width: double.infinity,
        height: coverHeight,
        color: Colors.grey.shade800,
        child: Image.file(File(coverUrl!), fit: BoxFit.cover),
      );
    }

    if (_isRemotePath(coverUrl)) {
      return Container(
        width: double.infinity,
        height: coverHeight,
        color: Colors.grey.shade800,
        child: Image.network(
          coverUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: coverHeight,
      color: Colors.grey.shade800,
    );
  }

  Widget buildProfileImage() {
    Widget avatar;
    if (_isLocalPath(profileUrl)) {
      avatar = CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        backgroundImage: FileImage(File(profileUrl!)),
      );
    } else if (_isRemotePath(profileUrl)) {
      avatar = CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(profileUrl!),
      );
    } else {
      avatar = CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        child: const Icon(Icons.person, size: 50, color: Color(0xFF3A5F8A)),
      );
    }
    return avatar;
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
