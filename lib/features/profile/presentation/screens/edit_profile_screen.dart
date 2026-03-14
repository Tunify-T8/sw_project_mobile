import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../data/dto/profile_dto.dart';
class EditProfileScreen extends StatefulWidget {
  final String userName;
  final String city;
  final String country;
  final String bio;
  final File? profileImage;
  final File? coverImage;

  const EditProfileScreen({
    super.key,
    required this.userName,
    required this.city,
    required this.country,
    required this.bio,
    this.profileImage,
    this.coverImage,
  });
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ////////////variables
  File? profileImage;
  File? coverImage;
  final double coverHeight = 150;
  final double profileHeight = 150;
  final _picker = ImagePicker();
   // pre-filled with current profile data, user edits these
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _bioController;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _cityController = TextEditingController(text: widget.city);
    _countryController = TextEditingController(text: widget.country);
    _bioController = TextEditingController(text: widget.bio);
    profileImage = widget.profileImage;
    coverImage = widget.coverImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final shouldLeave = await showDiscardDialog();
    return shouldLeave ?? false;
  }


  Future<bool?> showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Are you sure?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You have unsaved changes that will be lost',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true), // discard
            child: const Text(
              'DISCARD CHANGES',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false), // stay
            child: const Text(
              'CONTINUE EDITING',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
      onPressed: () {
        setState(() => _hasChanges = false);
        Navigator.pop(context, ProfileDto(
          userName: _nameController.text,
          city: _cityController.text,
          country: _countryController.text,
          bio: _bioController.text,
          profileImagePath: profileImage?.path,
          coverImagePath: coverImage?.path,
        ));
      },

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () async {
          final shouldLeave = await _onWillPop();
          if (shouldLeave && context.mounted) Navigator.pop(context);
        },
      ),
      title: const Text(
        'Edit profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        buildSaveButton(context),
      ],
    );
  }
  Future<void> pickImage({required bool isCover}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _hasChanges = true;
        if (isCover) {
          coverImage = File(picked.path);
        } else {
          profileImage = File(picked.path);
        }
      });
    }
  }
Widget buildCoverImage() {
  Widget coverContent;
  if (coverImage != null) {
    coverContent = Image.file(coverImage!, fit: BoxFit.cover);
  } else {
    coverContent = const SizedBox.shrink();
  }

  return GestureDetector(
    onTap: () => pickImage(isCover: true),
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
    onTap: () => pickImage(isCover: false),
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

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              buildCoverImage(),
              Positioned(
                top: coverHeight - profileHeight / 2,
                left: 25,
                child: buildProfileImage(),
              ),
            ],
          ),
          SizedBox(height: profileHeight / 2 + 8),
        ],
      ),
    );
  }
  @override
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }
}