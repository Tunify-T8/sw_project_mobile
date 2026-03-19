import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_share_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileProvider _provider;
  final double profileHeight = 150;
  final double coverHeight = 150;

  final nameStyle = TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white);
  final followerStyle = TextStyle(fontSize: 18, color: Colors.grey.shade200);
  final bioStyle = TextStyle(fontSize: 16, color: Colors.grey.shade400, height: 1.5);

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

  List<Map<String, String>> tracks = [
    {'title': 'Track 1', 'duration': '3:45'},
    {'title': 'Track 2', 'duration': '4:20'},
  ];

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
      });
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProfileLoaded);
    super.dispose();
  }

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
            onPressed: () => ProfileShareSheet(
              context: context,
              userName: userName,
              bio: bio,
              followersCount: followersCount,
              tracksCount: _provider.state.profile?.tracksCount ?? 0,
              profileImage: profileImage,
              instagram: instagram,
              twitter: twitter,
              website: website,
              bioStyle: bioStyle,
            ).show(),
          ),
        ],
      ),
      body: _provider.state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _provider.state.isError
              ? Center(child: Text(_provider.state.errorMessage ?? 'Error',
                  style: const TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(
                        coverHeight: coverHeight,
                        profileHeight: profileHeight,
                        coverUrl: _provider.state.profile?.coverImagePath,
                        profileUrl: _provider.state.profile?.profileImagePath,
                      ),
                      SizedBox(height: profileHeight / 2 + 8),
                      ProfileInfo(
                        userName: userName,
                        city: city,
                        country: country,
                        bio: bio,
                        followersCount: followersCount,
                        followingCount: followingCount,
                        nameStyle: nameStyle,
                        bioStyle: bioStyle,
                        followerStyle: followerStyle,
                        onShowMore: () => ProfileShareSheet(
                          context: context,
                          userName: userName,
                          bio: bio,
                          followersCount: followersCount,
                          tracksCount: _provider.state.profile?.tracksCount ?? 0,//to read I replaced the local variable
                          profileImage: profileImage,
                          instagram: instagram,
                          twitter: twitter,
                          website: website,
                          bioStyle: bioStyle,
                        ).showInfoSheet(),
                        actionButtons: ProfileActionButtons(
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
                          provider: _provider,
                          onUpdate: (updated) => _provider.updateProfile(updated),
                          onUserTypeChanged: (type) => setState(() => userType = type),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}