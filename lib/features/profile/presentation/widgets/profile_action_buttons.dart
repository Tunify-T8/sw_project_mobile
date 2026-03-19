import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/dto/profile_dto.dart';
import '../screens/edit_profile_screen.dart';
import '../providers/profile_provider.dart';

class ProfileActionButtons extends StatelessWidget {
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
  final ProfileProvider provider;
  final Future<void> Function(ProfileDto) onUpdate;
  final void Function(String) onUserTypeChanged;

  const ProfileActionButtons({
    super.key,
    required this.userName,
    required this.bio,
    required this.city,
    required this.country,
    required this.profileImage,
    required this.coverImage,
    required this.instagram,
    required this.twitter,
    required this.website,
    required this.userType,
    required this.provider,
    required this.onUpdate,
    required this.onUserTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  profileImageUrl: provider.state.profile?.profileImagePath,
                  coverImageUrl: provider.state.profile?.coverImagePath,
                )),
              );
              if (result != null) {
                final updated = ProfileDto(
                // server-controlled; carry from provider
                id: provider.state.profile!.id,
                email: provider.state.profile!.email,
                role: provider.state.profile!.role,
                tracksCount: provider.state.profile!.tracksCount,
                likesReceived: provider.state.profile!.likesReceived,
                isActive: provider.state.profile!.isActive,
                isVerified: provider.state.profile!.isVerified,
                followersCount: provider.state.profile!.followersCount,
                followingCount: provider.state.profile!.followingCount,
                // user-editable; from result of updates
                userName: result.userName,
                bio: result.bio,
                city: result.city,
                country: result.country,
                visibility: result.visibility,
                instagram: result.instagram,
                twitter: result.twitter,
                website: result.website,
                userType: result.userType,
                profileImagePath: result.profileImagePath == ''
                    ? null
                    : (result.profileImagePath ?? provider.state.profile?.profileImagePath),
                coverImagePath: result.coverImagePath == ''
                    ? null
                    : (result.coverImagePath ?? provider.state.profile?.coverImagePath),
                );
                onUserTypeChanged(result.userType);
                await onUpdate(updated);
              }
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
            onPressed: () {},
          ),
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
  }
}