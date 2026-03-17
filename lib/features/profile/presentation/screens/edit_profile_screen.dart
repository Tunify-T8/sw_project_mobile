import 'dart:io';
import 'package:flutter/material.dart';
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
    final String? website;
    final String userType;
    final String? profileImageUrl;
    final String? coverImageUrl;//3lshan yfdal shayef el soora

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
  late final TextEditingController _websiteController;

  bool _hasChanges = false;//need to track to use when you save and when you try to exit withoiut saving
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
    _websiteController = TextEditingController(text: widget.website ?? '');
    profileImage = widget.profileImage;
    coverImage = widget.coverImage;
    profileImageUrl = widget.profileImageUrl;
    coverImageUrl = widget.coverImageUrl;
    _isArtist = widget.userType == 'ARTIST';
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
          onPressed: () async {

          String? profileUrl;
          String? coverUrl;
          
          if (profileImage != null) {
            profileUrl = await uploadImage(profileImage!);
          }
          else if (_profileImageDeleted){
             profileUrl = '';  // says "deleted"
          }

          if (coverImage != null) {
            coverUrl = await uploadImage(coverImage!);
          }else if (_coverImageDeleted) {
             coverUrl = '';  // says "deleted"
          }

          setState(() => _hasChanges = false);

          Navigator.pop(context, ProfileDto(
            userName: _nameController.text,
            city: _cityController.text,
            country: _countryController.text,
            bio: _bioController.text,
            profileImagePath: profileUrl,
            coverImagePath: coverUrl,
            instagram: _instagramController.text.isEmpty ? null : _instagramController.text,
            twitter: _twitterController.text.isEmpty ? null : _twitterController.text,
            website: _websiteController.text.isEmpty ? null : _websiteController.text,
            userType: _isArtist ? 'ARTIST' : 'LISTENER',
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

Future<void> pickImage({required bool isCover, ImageSource source = ImageSource.gallery}) async {
  final picked = await _picker.pickImage(source: source);//source 3lshan ya2ma camera ya2ma gallery
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
            coverImageUrl: coverImageUrl,    // add
            profileImageUrl: profileImageUrl,
            onCoverPick: (source) => pickImage(isCover: true, source: source),//8yrataha 3lshan ta5od camera aw gallery
            onProfilePick: (source) => pickImage(isCover: false, source: source),
            onCoverDelete: () => setState(() {   // to delete
              coverImage = null;
              _coverImageDeleted = true;
              _hasChanges = true;
            }),
            onProfileDelete: () => setState(() { // to delete
              profileImage = null;
              _profileImageDeleted= true;
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
            websiteController: _websiteController,
            onChanged: () => setState(() => _hasChanges = true),
          ),
          buildAccountTypeToggle(),//is artist aw listener
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
          activeColor: const Color(0xFF3A5F8A),
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