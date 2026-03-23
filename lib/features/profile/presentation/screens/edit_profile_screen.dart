import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/dto/profile_dto.dart';
import '../widgets/discard_dialog.dart';
import '../widgets/edit_profile_images.dart';
import '../widgets/edit_profile_text_fields.dart';
import 'package:country_picker/country_picker.dart';
import '../widgets/edit_profile_links.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import '../../data/services/image_server_upload.dart';//cloudinary

class EditProfileScreen extends StatefulWidget {
  final String userName;
  final String bio;
  final String city;
  final String country;
  final File? profileImage;
  final File? coverImage;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? spotify;
  final String? tiktok;
  final String? soundcloud;
  final String userType;
  final String? profileImageUrl;
  final String? coverImageUrl; //3lshan yfdal shayef el soora

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
    this.youtube,
    this.spotify,
    this.tiktok,
    this.soundcloud,
    this.profileImageUrl,
    this.coverImageUrl,
    this.userType = 'ARTIST',
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ////////////cloudinary

  //////////variables
  File? profileImage;
  File? coverImage;
  /////to have editscreen up to date with images
  String? profileImageUrl;
  String? coverImageUrl;
  //// 3lshan amsa7 el sa7
  bool _profileImageDeleted = false;
  bool _coverImageDeleted = false;
  /////
  final _picker = ImagePicker();
  ///////////ba2fel el save le7ad ma ye
  //bool _isUploading = false;
  // pre-filled with current profile data, user edits these
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _cityController;
  late final TextEditingController _countryController;
  late final TextEditingController _instagramController;
  late final TextEditingController _twitterController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _spotifyController;
  late final TextEditingController _tiktokController;
  late final TextEditingController _soundcloudController;

  bool _hasChanges =
      false; //need to track to use when you save and when you try to exit withoiut saving
  late bool _isArtist;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _cityController = TextEditingController(text: widget.city);
    _countryController = TextEditingController(text: widget.country);
    _bioController = TextEditingController(text: widget.bio);
    _instagramController = TextEditingController(text: widget.instagram ?? '');
    _twitterController = TextEditingController(text: widget.twitter ?? '');
    _youtubeController = TextEditingController(text: widget.youtube ?? '');
    _spotifyController = TextEditingController(text: widget.spotify ?? '');
    _tiktokController = TextEditingController(text: widget.tiktok ?? '');
    _soundcloudController = TextEditingController(text: widget.soundcloud ?? '');
    profileImage = widget.profileImage;
    coverImage = widget.coverImage;
    profileImageUrl = widget.profileImageUrl;
    coverImageUrl = widget.coverImageUrl;
    _isArtist = widget.userType == 'ARTIST';
  }

  @override
  void dispose() {
    //dipose happens when teh screen is closed to clear the memory of controllers and avoid memory leaks
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    _spotifyController.dispose();
    _tiktokController.dispose();
    _soundcloudController.dispose();
    super.dispose();
  }

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/denreb1dd/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ml_default'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      return jsonMap['secure_url'];
    }

    return null;
  }

  Future<String?> _resolveSavedImagePath(
    File? imageFile, {
    required String fallbackFailureMessage,
  }) async {
    if (imageFile == null) {
      return null;
    }

    try {
      final uploadedUrl = await uploadImage(imageFile);
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        return uploadedUrl;
      }
    } catch (_) {
      // Fall back to local storage below.
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(fallbackFailureMessage)));
    }

    return imageFile.path;
  }

  Future<bool> _onWillPop() async {
    //if user goes back if has changes is true then display discard dialog
    if (!_hasChanges) return true;
    final shouldLeave = await showDiscardDialog(context);
    if (shouldLeave != null) {
      return shouldLeave; // user pressed el howa ah discard aw continue editing
    } else {
      return false; // user das bara fa hy2fel we ysibo ykml editing
    }
  }

  Widget buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () async {
          String? profileUrl;
          String? coverUrl;

          if (profileImage != null) {
            profileUrl = await _resolveSavedImagePath(
              profileImage,
              fallbackFailureMessage:
                  'Profile image upload failed, so we saved the local image instead.',
            );
          } else if (_profileImageDeleted) {
            profileUrl = ''; // says "deleted"
          }

          if (coverImage != null) {
            coverUrl = await _resolveSavedImagePath(
              coverImage,
              fallbackFailureMessage:
                  'Cover image upload failed, so we saved the local image instead.',
            );
          } else if (_coverImageDeleted) {
            coverUrl = ''; // says "deleted"
          }

          if (!context.mounted) return;
          setState(() => _hasChanges = false);

          Navigator.of(context).pop(
            ProfileDto(
              userName: _nameController.text,
              city: _cityController.text,
              country: _countryController.text,
              bio: _bioController.text,
              profileImagePath: profileUrl,
              coverImagePath: coverUrl,
              instagram: _instagramController.text.isEmpty
                  ? null
                  : _instagramController.text,
              twitter: _twitterController.text.isEmpty
                  ? null
                  : _twitterController.text,
              youtube: _youtubeController.text.isEmpty
                  ? null
                  : _youtubeController.text,
              spotify: _spotifyController.text.isEmpty
                  ? null
                  : _spotifyController.text,
              tiktok: _tiktokController.text.isEmpty
                  ? null
                  : _tiktokController.text,
              soundcloud: _soundcloudController.text.isEmpty
                  ? null
                  : _soundcloudController.text,
              userType: _isArtist ? 'ARTIST' : 'LISTENER',
              visibility:
                  'PUBLIC', // carried over as is, edit screen doesn't change this
            ),
          );
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
      actions: [buildSaveButton(context)],
    );
  }

  Future<void> pickImage({
    required bool isCover,
    ImageSource source = ImageSource.gallery,
  }) async {
    XFile? picked;

    try {
      picked = await _picker.pickImage(
        source: source,
      ); //source 3lshan ya2ma camera ya2ma gallery
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'The emulator camera could not be opened.'
                : 'The emulator photo library could not be opened.',
          ),
        ),
      );
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not open the image picker right now.'),
        ),
      );
      return;
    }

    if (!mounted) return;

    final pickedFile = picked;
    if (pickedFile == null) return;

    setState(() {
      _hasChanges = true;
      if (isCover) {
        //lw el cover el et8yr 8yr el cover image
        coverImage = File(pickedFile.path);
        _coverImageDeleted = false;
      } else {
        //8er kda 7ot el sora el e5trha fel profile
        profileImage = File(pickedFile.path);
        _profileImageDeleted = false;
      }
    });
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditProfileImages(
            coverImage: coverImage,
            profileImage: profileImage,
            coverImageUrl: coverImageUrl, // add
            profileImageUrl: profileImageUrl,
            onCoverPick: (source) => pickImage(
              isCover: true,
              source: source,
            ), 
            onProfilePick: (source) =>
                pickImage(isCover: false, source: source),
            onCoverDelete: () => setState(() {
              coverImage = null;
              coverImageUrl = null;
              _coverImageDeleted = true;
              _hasChanges = true;
            }),
            onProfileDelete: () => setState(() {
              profileImage = null;
              profileImageUrl = null;
              _profileImageDeleted = true;
              _hasChanges = true;
            }),
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
            youtubeController: _youtubeController,
            spotifyController: _spotifyController,
            tiktokController: _tiktokController,
            soundcloudController: _soundcloudController,
            onChanged: () => setState(() => _hasChanges = true),
          ),
          buildAccountTypeToggle(), //is artist aw listener
        ],
      ),
    );
  }

  Widget buildAccountTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account type',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                _isArtist ? 'Artist' : 'Listener',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Switch(
            value: _isArtist,
            activeThumbColor: const Color(0xFF3A5F8A),
            onChanged: (val) {
              setState(() {
                _isArtist = val;
                _hasChanges = true;
              });
            },
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
