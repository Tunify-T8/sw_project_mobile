import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileImages extends StatelessWidget {
  final File? coverImage;
  final File? profileImage;
  final String? profileImageUrl;
  final String? coverImageUrl;
  // final VoidCallback onCoverTap;
  // final VoidCallback onProfileTap;
  final void Function(ImageSource) onCoverPick;
  final void Function(ImageSource) onProfilePick;

  final VoidCallback onCoverDelete;    // lw hamsa7 cover
  final VoidCallback onProfileDelete;//lw hamsa7 profile

  static const double coverHeight = 150;
  static const double profileHeight = 150;

  const EditProfileImages({
    super.key,
    required this.coverImage,
    required this.profileImage,
    required this.onCoverPick,
    required this.onProfilePick,
    required this.onCoverDelete,    //el zwedtohom fo2
    required this.onProfileDelete,  
    this.profileImageUrl,   // add
    this.coverImageUrl,  
  });

void showImageOptions(BuildContext context, {required bool isCover}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
          title: const Text('Take photo', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            isCover
                ? onCoverPick(ImageSource.camera)
                : onProfilePick(ImageSource.camera);
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined, color: Colors.white),
          title: const Text('Choose from library', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            isCover
                ? onCoverPick(ImageSource.gallery)
                : onProfilePick(ImageSource.gallery);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.white),
          title: Text(
            isCover ? 'Delete header image' : 'Delete profile image',
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            Navigator.pop(context);
            isCover ? onCoverDelete() : onProfileDelete();
          },
        ),
      ],
    ),
  );
}
  Widget buildCoverImage(BuildContext context) {
  Widget coverContent;
  if (coverImage != null) {
    coverContent = Image.file(coverImage!, fit: BoxFit.cover);
  } else if (coverImageUrl != null) {                          // add this
    coverContent = Image.network(coverImageUrl!, fit: BoxFit.cover);
  } else {
    coverContent = const SizedBox.shrink();
  }

  return GestureDetector(
    onTap:()=>showImageOptions(context, isCover: true),
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

Widget buildProfileImage(BuildContext context) {
  ImageProvider? image;
  if (profileImage != null) {
    image = FileImage(profileImage!);
  } else if (profileImageUrl != null) {
    image = NetworkImage(profileImageUrl!);  // add this
  }

  Widget? avatarChild;
  if (profileImage == null) {
    avatarChild = const Icon(Icons.person, size: 50, color: Color(0xFF3A5F8A));
  }

  return GestureDetector(
    onTap: ()=> showImageOptions(context, isCover: false),
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
        buildCoverImage(context),
        Positioned(
          top: coverHeight - profileHeight / 2,
          left: 25,
          child: buildProfileImage(context),
        ),
      ],
    );
  }
}