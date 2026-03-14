import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/dto/profile_dto.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class  _ProfileScreenState extends State<ProfileScreen> {
  final double profileHeight = 150;
  final double coverHeight = 150;
  ///styles 
  final nameStyle = TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.white);
  final followerStyle = TextStyle( fontSize: 18, color: Colors.grey.shade200);
  final bioStyle = TextStyle(fontSize: 16, color: Colors.grey.shade400, height: 1.5);
  // I wrote the mockdata i used as variables to easily replace with api later
  String userName = 'Darine Sherif';
  String city = 'Cairo';
  String country = 'Egypt';
  int followersCount = 300;
  int followingCount = 1;
  List<String> genres = ['HipHop', 'Jazz', 'Electronic'];
  String bio = 'Music lover based in Cairo 🎧';
  //image files
  File? profileImage;
  File? coverImage;
  ///////////////////////

  Widget buildProfileImage() {
    if(profileImage!=null){
    return CircleAvatar(
        radius: profileHeight/2,
        backgroundColor: Colors.grey,
        backgroundImage:FileImage(profileImage!),

      );
      }
      else{
        return CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey,
        child: const Icon(Icons.person, size: 50, color: Color(0xFF3A5F8A)),
       );
      }
  }

  Widget buildCoverImage() {
    if (coverImage != null) {
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
    child: Text('📍$city, $country',style:bioStyle), 
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
    final links = [//I will hardcode the links first to see what appears then I will take it from api
      {'icon': Icons.camera_alt, 'url': 'https://instagram.com/darineelfeel'},
      {'icon': Icons.language, 'url': 'https://yourwebsite.com'},//these two are an example to add more icons do that in edit
    ];//when I get the api it would probably look like this 
    // final links = user.webLinks.map((link) => {
    //   'icon': iconForPlatform(link.platform),
    //   'url': link.url,
    // }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: links.map((link) => IconButton(
          onPressed: () async {
             // launch url later when I get api
          // launchUrl(Uri.parse(link['url'] as String));
          //print(link['url']); // just prints for now so I can see it works for now
    
          final url = Uri.parse(link['url'] as String);
          await launchUrl(url, mode: LaunchMode.externalApplication);
          }, // add url_launcher here later->what I'm trying to do now
          icon: Icon(
            link['icon'] as IconData,
            color: Colors.white,
            size:30,
          ),
        )).toList(),
      ),
    );
  }

  Widget buildIcon({//avoid redundancy; do all icons with it, reusable code
    required IconData icon,
    required VoidCallback onPressed,
    double size = 28,
    Color color = Colors.white,
    bool filled = false, // true for play button (white circle)
  }) {
    if (filled) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.black, size: size),
        ),
      );
    }
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: size),
    );
  }

  Widget buildActionButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Row(
      children: [
        buildIcon(
          icon: Icons.edit_outlined,
          onPressed: () async {
            final result = await Navigator.push<ProfileDto>(
              context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(
                userName: userName,
                city: city,
                country: country,
                bio: bio,
                profileImage: profileImage,
                coverImage: coverImage,
              ))
            );
            if (result != null) {
              setState(() {
                userName = result.userName;
                city = result.city;
                country = result.country;
                bio = result.bio;
                if (result.profileImagePath != null) {
                  profileImage = File(result.profileImagePath!);
                }
                if (result.coverImagePath != null) {
                  coverImage = File(result.coverImagePath!);
                }
              });
            }
          },
        ),
        const Spacer(),
        buildIcon(
            icon: Icons.shuffle,
            onPressed: () {},
          ),
        buildIcon(
            icon: Icons.play_arrow,
            onPressed: () {},
            filled: true,  
            size:28,
          ), 
      ],
    ),
  );
  ////popup menu
  PopupMenuItem<String> buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
  Widget buildMoreMenu() => PopupMenuButton<String>(
    color: const Color(0xFF1A1A1A),
      onSelected: (value) {
        if (value == 'share') {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const ShareScreen()));
        } else if (value == 'star') {
          //Navigator.push(context, MaterialPageRoute(builder: (_) =>const EditProfileScreen()));
        } else if (value == 'copy_link') {
          print('copy link');
        }
      },
    icon: const Icon(Icons.more_vert, color: Colors.white),
    itemBuilder: (context) => [
      buildMenuItem(value: 'share', icon: Icons.share_outlined, label: 'Share'),
      buildMenuItem(value: 'star', icon: Icons.star_outline, label: 'Star'),
      buildMenuItem(value: 'copy_link', icon: Icons.link, label: 'Copy link'),
    ],
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
          // IconButton(
          //   icon: const Icon(Icons.more_vert),
          //   onPressed: () {},
          // ),
           buildMoreMenu(),
        ],
      ),
      body: SingleChildScrollView(
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