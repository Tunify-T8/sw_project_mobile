import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/dto/profile_dto.dart';
import '../widgets/discard_dialog.dart';
import '../widgets/edit_profile_images.dart';
import '../widgets/edit_profile_text_fields.dart';
import 'package:country_picker/country_picker.dart';
import '../widgets/edit_profile_links.dart';

class EditProfileScreen extends StatefulWidget {
    final String userName;
    final String bio;
    final String city;
    final String country;
    final File? profileImage;
    final File? coverImage;
    final String? instagram;
    final String? twitter;
    final String? website;

  const EditProfileScreen({
    super.key,
    required this.userName,
    required this.bio,
    required this.city,
    required this.country,
    this.profileImage,
    this.coverImage,
    this.instagram,
    this.twitter,
    this.website,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ////////////variables
  File? profileImage;
  File? coverImage;
  final _picker = ImagePicker();
  // pre-filled with current profile data, user edits these
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _instagramController;
  late final TextEditingController _twitterController;
  late final TextEditingController _websiteController;

  bool _hasChanges = false;//need to track to use when you save and when you try to exit withoiut saving

  @override
  void initState() {
    super.initState();//thsi is what the values are initially
      _nameController = TextEditingController(text: widget.userName);
      _cityController = TextEditingController(text: widget.city);
      _countryController = TextEditingController(text: widget.country);
      _bioController = TextEditingController(text: widget.bio);
      _instagramController = TextEditingController(text: widget.instagram ?? '');
      _twitterController = TextEditingController(text: widget.twitter ?? '');
      _websiteController = TextEditingController(text: widget.website ?? '');
      profileImage = widget.profileImage;
      coverImage = widget.coverImage;
  }

  @override
  void dispose() {//dipose happens when teh screen is closed to clear the memory of controllers and avoid memory leaks
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {//if user goes back if has changes is true then display discard dialog
    if (!_hasChanges) return true;
    final shouldLeave = await showDiscardDialog(context);
    if (shouldLeave != null) {
      return shouldLeave;// user pressed el howa ah discard aw continue editing
    } else {
      return false;// user das bara fa hy2fel we ysibo ykml editing
    }
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
          instagram: _instagramController.text.isEmpty ? null : _instagramController.text,
          twitter: _twitterController.text.isEmpty ? null : _twitterController.text,
          website: _websiteController.text.isEmpty ? null : _websiteController.text,
        ));
          //btrg3 el profile el mt3dl fih
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
        if (isCover) {//lw el cover el et8yr 8yr el cover image
          coverImage = File(picked.path);
        } else {//8er kda 7ot el sora el e5trha fel profile
          profileImage = File(picked.path);
        }
      });
    }
  }

  Widget buildBody() {//a scrollable bode: images(top),fields (bottom)
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditProfileImages(
            coverImage: coverImage,
            profileImage: profileImage,
            onCoverTap: () => pickImage(isCover: true),
            onProfileTap: () => pickImage(isCover: false),
          ),
          SizedBox(height: EditProfileImages.profileHeight / 2 + 8),
          EditProfileTextFields(
            nameController: _nameController,
            cityController: _cityController,
            countryController: _countryController,
            bioController: _bioController,
            onChanged: () => setState(() => _hasChanges = true),
            onCountryTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (Country country) {
                  setState(() {
                    _countryController.text = country.name;
                    _hasChanges = true;
                  });
                },
              );
            },
          ),
          EditProfileLinks(
            instagramController: _instagramController,
            twitterController: _twitterController,
            websiteController: _websiteController,
            onChanged: () => setState(() => _hasChanges = true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context),
      body: buildBody(),
    );
  }
}