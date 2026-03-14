import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'edit_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/dto/profile_dto.dart';
import 'package:flutter/foundation.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
//import '../../data/dto/profile_dto.dart';
//import 'package:share_plus/share_plus.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class  _ProfileScreenState extends State<ProfileScreen> {
  late ProfileProvider _provider;//di bel apis
  final double profileHeight = 150;
  final double coverHeight = 150;
  ///styles 
  final nameStyle = TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.white);
  final followerStyle = TextStyle( fontSize: 18, color: Colors.grey.shade200);
  final bioStyle = TextStyle(fontSize: 16, color: Colors.grey.shade400, height: 1.5);
  // I wrote the mockdata i used as variables to easily replace with api later
  // String userName = 'Darine Sherif';
  // String city = 'Cairo';
  // String country = 'Egypt';
  // String? instagram;
  // String? twitter;
  // String? website;
  // int followersCount = 300;
  // int followingCount = 1;
  String userName = '';
  String city = '';
  String country = '';
  String? instagram;
  String? twitter;
  String? website;
  int followersCount = 0;
  int followingCount = 0;
  List<String> genres = [];
  String bio = '';
  File? profileImage;
  File? coverImage;
  String userType = 'ARTIST';
 // List<String> genres = ['HipHop', 'Jazz', 'Electronic'];
  //String bio = 'Music lover based in Cairo 🎧';
  //image files
  //File? profileImage;
  //File? coverImage;
  //////tracks for now
  List<Map<String, String>> tracks = [
    {'title': 'Track 1', 'duration': '3:45'},
    {'title': 'Track 2', 'duration': '4:20'},
  ];
  ///////////////////////
  @override
  void initState() {
    super.initState();
    _provider = ProfileProvider();
    _provider.addListener(_onProfileLoaded);
    _provider.loadProfile();
  }

  void _onProfileLoaded() {
    if (_provider.state.isSuccess && _provider.state.profile != null) {
      final profile = _provider.state.profile!;
      setState(() {
        userName = profile.userName;
        bio = profile.bio;
        city = profile.city;
        country = profile.country;
        followersCount = profile.followersCount;
        followingCount = profile.followingCount;
        instagram = profile.instagram;
        twitter = profile.twitter;
        website = profile.website;
        userType = profile.userType;
        if (profile.profileImagePath != null) {
          // network image — handle separately
        }
      });
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProfileLoaded);
    super.dispose();
  }
  //////
  Widget buildProfileImage() {
    final avatarUrl = _provider.state.profile?.profileImagePath;
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(avatarUrl),
      );
    } else if (profileImage != null) {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        backgroundImage: FileImage(profileImage!),
      );
    } else {
      return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        child: const Icon(Icons.person, size: 50, color: Color(0xFF3A5F8A)),
      );
    }
  }

  Widget buildCoverImage() {
    final coverUrl = _provider.state.profile?.coverImagePath;
    if (coverUrl != null) {
      return Container(
        width: double.infinity,
        height: coverHeight,
        color: Colors.grey.shade800,
        child: Image.network(coverUrl, fit: BoxFit.cover),
      );
    } else if (coverImage != null) {
      return Container(
        width: double.infinity,
        height: coverHeight,
        color: Colors.grey.shade800,
        child: Image.file(coverImage!, fit: BoxFit.cover),
      );
    } else {
      return Container(
        width: double.infinity,
        height: coverHeight,
        color: Colors.grey.shade800,
      );
    }
  }
  Widget buildName() => Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Text(userName,style:nameStyle),
  );
    Widget buildBio() => Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Text(bio,style:bioStyle),
  );
  Widget buildLocation() => Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Text('📍$city, $country', style: bioStyle),
  );
  Widget buildFollowerCount() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: [
          GestureDetector(
            onTap:(){
              //Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowerScreen()));
            },
          child: Text('$followersCount Followers', style: followerStyle),
          ),
          Text('  ·  ', style: followerStyle),
          GestureDetector(
            onTap:(){
              //Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingScreen()));
            },
            child:Text('$followingCount Following', style: followerStyle),
          ),
        ],
      ),
    );
  }
 Widget buildSocialLinks() {
  final links = [
    if (instagram != null && instagram!.isNotEmpty)
      {'icon': Icons.camera_alt, 'url': instagram!, 'label': instagram!},
    if (twitter != null && twitter!.isNotEmpty)
      {'icon': Icons.alternate_email, 'url': twitter!, 'label': twitter!},
    if (website != null && website!.isNotEmpty)
      {'icon': Icons.language, 'url': website!, 'label': website!},
  ];

  if (links.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: links.map((link) => GestureDetector(
        onTap: () async {
          final url = Uri.parse(link['url'] as String);
          await launchUrl(url, mode: LaunchMode.externalApplication);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(link['icon'] as IconData, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(link['label'] as String, style: bioStyle),
            ],
          ),
        ),
      )).toList(),
    ),
  );
}
  Widget buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 28),
          onPressed: () async {
            final result = await Navigator.push<ProfileDto>(
              context,
              MaterialPageRoute(builder: (_) => EditProfileScreen(
                userName: userName,
                bio: bio,
                city: city,
                country: country,
                profileImage: profileImage,
                coverImage: coverImage,
                instagram: instagram,
                twitter: twitter,
                website: website,
                userType: userType,
              ))
            );
            // if (result != null) {
            //   setState(() {
            //     userName = result.userName;
            //     bio = result.bio;
            //     city = result.city;
            //     country= result.country;
            //     instagram = result.instagram;
            //     twitter = result.twitter;
            //     website = result.website;
            //     if (result.profileImagePath != null) profileImage = File(result.profileImagePath!);
            //     if (result.coverImagePath != null) coverImage = File(result.coverImagePath!);
            //   });
            // }

            // if (result != null) {
            //   await _provider.updateProfile(result);
            // }
            if (result != null) {
              final updated = ProfileDto(
                userName: result.userName,
                bio: result.bio,
                city: result.city,
                country: result.country,
                visibility: result.visibility,
                followersCount: result.followersCount,
                followingCount: result.followingCount,
                instagram: result.instagram,
                twitter: result.twitter,
                website: result.website,
                userType: result.userType,
                profileImagePath: result.profileImagePath ?? _provider.state.profile?.profileImagePath,
                coverImagePath: result.coverImagePath ?? _provider.state.profile?.coverImagePath,
              );
              setState(() => userType = result.userType);
              await _provider.updateProfile(updated);
            }
          },
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
          onPressed: () {},
        ),
      // play needs to be like this to show the filled circle
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.black, size: 28),
          onPressed: () {},
        ),
      ),
      ],
    ),
  );
  ////da el three dots menu
    void showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // profile info el heya elmafrodd bas el name,followers, tracks
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('$followersCount Followers · ${tracks.length} Tracks',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // share actions row el gowa el three dots
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),//bdl ma kont ba3od a3mlo be eidi
              child: Row(
                children: [
                  buildShareAction(Icons.send, 'Message'),
                 buildShareAction(Icons.copy, 'Copy Link'),
                  buildShareAction(Icons.copy, 'Copy Link', onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'https://soundcloud.com/darineelfeel'));
                    Navigator.pop(context); // close bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }),
                  // buildShareAction(Icons.share, 'Share', onTap: () {
                  //   Share.share('https://soundcloud.com/darineelfeel');
                  // }),
                  ///// bgrb copy to clipboard
                  buildShareAction(Icons.message, 'WhatsApp'),
                  buildShareAction(Icons.messenger_outline, 'SMS'),
                  buildShareAction(Icons.person, 'Instagram stories'),
                  buildShareAction(Icons.person, 'Facebook stories'),
                  buildShareAction(Icons.message, 'WhatsApp'),
                  buildShareAction(Icons.more, 'More'),
                  //add more when needed
                ],
              ),
            ),
            const SizedBox(height: 12),
            //start station
            ListTile(
              leading: const Icon(Icons.radio, color: Colors.white),
              title: const Text('Start station', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
            // view info
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('View info', style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
    
    Widget buildShareAction(IconData icon, String label, {VoidCallback? onTap}) => SizedBox(
      width: 80,
      child: GestureDetector(
        onTap: onTap,  // ← uses the passed onTap
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => showShareSheet(),
          ),
          // buildMoreMenu(),
        ],
      ),
body: _provider.state.isLoading
  ? const Center(child: CircularProgressIndicator())
  : _provider.state.isError
    ? Center(child: Text(_provider.state.errorMessage ?? 'Error', style: const TextStyle(color: Colors.white)))
    : SingleChildScrollView(
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
                  child: buildProfileImage(),//built like a stack this way, profile and cover overlapping is easy
                ),
              ],
            ),
            SizedBox(height: profileHeight / 2 + 8),//I am putting sizeboxes to add space
            buildName(),
            const SizedBox(height: 18),
            buildLocation(),
            const SizedBox(height:18),
            buildBio(),
            const SizedBox(height:18),
            buildFollowerCount(),
            const SizedBox(height:18),
            //buildEditIcon(),
            buildActionButtons(),
            const SizedBox(height: 18),
            buildSocialLinks(),
            const SizedBox(height:18),
          ],
        ),
      ),
    
    );
  }
  
}