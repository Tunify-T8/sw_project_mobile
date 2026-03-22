import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/dto/profile_dto.dart';
import '../screens/edit_profile_screen.dart';
import '../providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileActionButtons extends ConsumerWidget {
final File? profileImage;
final File? coverImage;
final String userType;

const ProfileActionButtons({
  super.key,
  required this.profileImage,
  required this.coverImage,
  required this.userType,
});
  @override
Widget build(BuildContext context, WidgetRef ref) {
     final profile = ref.watch(profileProvider).profile;
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
                userName: profile?.userName ?? '',
                bio: profile?.bio ?? '',
                city: profile?.city ?? '',
                country: profile?.country ?? '',
                profileImage: profileImage,
                coverImage: coverImage,
                instagram: profile?.instagram,
                twitter: profile?.twitter,
                youtube: profile?.youtube,
                spotify: profile?.spotify,
                tiktok: profile?.tiktok,
                soundcloud: profile?.soundcloud,
                userType: profile?.userType ?? 'ARTIST',
                profileImageUrl: profile?.profileImagePath,  // ← HERE
                coverImageUrl: profile?.coverImagePath,      // ← HERE
                )),
              );
              if (result != null) {
                final updated = ProfileDto(
                // server-controlled
                id: profile!.id,               // ← HERE
                email: profile.email,          // ← HERE
                role: profile.role,            // ← HERE
                tracksCount: profile.tracksCount,     // ← HERE
                likesReceived: profile.likesReceived, // ← HERE
                isActive: profile.isActive,           // ← HERE
                isVerified: profile.isVerified,       // ← HERE
                followersCount: profile.followersCount, // ← HERE
                followingCount: profile.followingCount, // ← HERE
                // user-editable
                userName: result.userName,
                bio: result.bio,
                city: result.city,
                country: result.country,
                visibility: result.visibility,
                instagram: result.instagram,
                twitter: result.twitter,
                youtube: result.youtube,
                spotify: result.spotify,
                tiktok: result.tiktok,
                soundcloud: result.soundcloud,
                userType: result.userType,
                profileImagePath: result.profileImagePath == ''  // ← HERE
                    ? null
                    : (result.profileImagePath ?? profile.profileImagePath),
                coverImagePath: result.coverImagePath == ''      // ← HERE
                    ? null
                    : (result.coverImagePath ?? profile.coverImagePath),
                );
                    await ref.read(profileProvider.notifier).updateProfile(updated);
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