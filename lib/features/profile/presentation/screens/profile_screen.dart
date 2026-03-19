import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_share_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
 ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  //late ProfileProvider _provider;
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
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

 @override
Widget build(BuildContext context) {
  final state = ref.watch(profileProvider);
  final profile = state.profile;

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
            userName: profile?.userName ?? '',
            bio: profile?.bio ?? '',
            followersCount: profile?.followersCount ?? 0,
            tracksCount: profile?.tracksCount ?? 0,
            profileImage: profileImage,
            instagram: profile?.instagram,
            twitter: profile?.twitter,
            website: profile?.website,
            bioStyle: bioStyle,
          ).show(),
        ),
      ],
    ),
    body: state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : state.isError
            ? Center(child: Text(state.errorMessage ?? 'Error',
                style: const TextStyle(color: Colors.white)))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      coverHeight: coverHeight,
                      profileHeight: profileHeight,
                      coverUrl: profile?.coverImagePath,
                      profileUrl: profile?.profileImagePath,
                    ),
                    SizedBox(height: profileHeight / 2 + 8),
                    ProfileInfo(
                      userName: profile?.userName ?? '',
                      city: profile?.city ?? '',
                      country: profile?.country ?? '',
                      bio: profile?.bio ?? '',
                      followersCount: profile?.followersCount ?? 0,
                      followingCount: profile?.followingCount ?? 0,
                      nameStyle: nameStyle,
                      bioStyle: bioStyle,
                      followerStyle: followerStyle,
                      onShowMore: () => ProfileShareSheet(
                        context: context,
                        userName: profile?.userName ?? '',
                        bio: profile?.bio ?? '',
                        followersCount: profile?.followersCount ?? 0,
                        tracksCount: profile?.tracksCount ?? 0,
                        profileImage: profileImage,
                        instagram: profile?.instagram,
                        twitter: profile?.twitter,
                        website: profile?.website,
                        bioStyle: bioStyle,
                      ).showInfoSheet(),
                      actionButtons: ProfileActionButtons(
                        profileImage: profileImage,
                        coverImage: coverImage,
                        userType: profile?.userType ?? 'ARTIST',
                      ),
                    ),
                  ],
                ),
              ),
  );
}
}