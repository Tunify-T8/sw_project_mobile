import 'package:flutter/material.dart';
import 'dart:io';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_share_sheet.dart';
import '../widgets/profile_tracks_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../audio_upload_and_management/presentation/providers/library_uploads_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../../audio_upload_and_management/presentation/utils/upload_player_launcher.dart';
import '../../../engagements_social_interactions/presentation/widgets/profile_reposts_section.dart';
import '../../../engagements_social_interactions/presentation/widgets/profile_likes_section.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../playlists/presentation/widgets/profile_playlists_section.dart';
import '../../../playlists/domain/entities/collection_type.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  //late ProfileProvider _provider;
  final double profileHeight = 150;
  final double coverHeight = 150;

  final nameStyle = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final followerStyle = TextStyle(fontSize: 18, color: Colors.grey.shade200);
  final bioStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey.shade400,
    height: 1.5,
  );

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      await ref.read(profileProvider.notifier).loadProfile();
      if (!mounted) return;
      await ref.read(libraryUploadsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      libraryUploadsProvider.select((value) => value.items.length),
      (previous, next) {
        if (previous != null && previous != next) {
          ref.read(profileProvider.notifier).loadProfile();
        }
      },
    );

    final state = ref.watch(profileProvider);
    final profile = state.profile;
    final uploadsState = ref.watch(libraryUploadsProvider);
    final uploadedTracks = uploadsState.items;

    print('CONSOLE: profile.isCertified = ${profile?.isCertified ?? false}');
//to check bs mzboot or not
    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.cast), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => ProfileShareSheet(
                context: context,
                userName: profile?.userName ?? '',
                bio: profile?.bio ?? '',
                followersCount: profile?.followersCount ?? 0,
                tracksCount: profile?.tracksCount ?? 0,
                profileImage: profileImage,
                profileImagePath: profile?.profileImagePath,
                instagram: profile?.instagram,
                twitter: profile?.twitter,
                youtube: profile?.youtube,
                spotify: profile?.spotify,
                tiktok: profile?.tiktok,
                soundcloud: profile?.soundcloud,
                bioStyle: bioStyle,
            ).show(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.isError
          ? Center(
              child: Text(
                state.errorMessage ?? 'Error',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : RefreshIndicator(
              color: Colors.orangeAccent,
              onRefresh: () async {
                await ref.read(profileProvider.notifier).loadProfile();
                await ref.read(libraryUploadsProvider.notifier).load();
              },
              child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    coverHeight: coverHeight,
                    profileHeight: profileHeight,
                    coverUrl: profile?.coverImagePath,
                    profileUrl: profile?.profileImagePath,
                    //isCertified: profile?.isCertified ?? false,
                  ),
                  SizedBox(height: profileHeight / 2 + 8),
                  ProfileInfo(
                    displayName: profile?.displayName ?? '',
                    userName: profile?.userName ?? '',
                    city: profile?.city ?? '',
                    country: profile?.country ?? '',
                    bio: profile?.bio ?? '',
                    followersCount: profile?.followersCount ?? 0,
                    followingCount: profile?.followingCount ?? 0,
                    isCertified: profile?.isCertified ?? false,
                    nameStyle: nameStyle,
                    bioStyle: bioStyle,
                    followerStyle: followerStyle,
                    userId: null,
                    onShowMore: () => ProfileShareSheet(
                      context: context,
                      userName: profile?.userName ?? '',
                      bio: profile?.bio ?? '',
                      followersCount: profile?.followersCount ?? 0,
                      tracksCount: profile?.tracksCount ?? 0,
                      profileImage: profileImage,
                      profileImagePath: profile?.profileImagePath,
                      instagram: profile?.instagram,
                      twitter: profile?.twitter,
                      youtube: profile?.youtube,
                      spotify: profile?.spotify,
                      tiktok: profile?.tiktok,
                      soundcloud: profile?.soundcloud,
                      bioStyle: bioStyle,
                    ).showInfoSheet(),
                    actionButtons: ProfileActionButtons(
                      profileImage: profileImage,
                      coverImage: coverImage,
                      userType: profile?.userType ?? 'ARTIST',
                      onPlay: uploadedTracks.isEmpty
                          ? null
                          : () => openUploadItemPlayer(
                                context,
                                ref,
                                uploadedTracks.first,
                                queueItems: uploadedTracks,
                                openScreen: false,
                              ),
                      onShuffle: uploadedTracks.isEmpty
                          ? null
                          : () {
                              final shuffled = List.of(uploadedTracks)..shuffle();
                              openUploadItemPlayer(
                                context,
                                ref,
                                shuffled.first,
                                queueItems: shuffled,
                                openScreen: false,
                              );
                            },
                    ),
                  ),
                  ProfileTracksSection(
                    items: uploadedTracks,
                    onTrackTap: (item) {
                      openUploadItemPlayer(
                        context,
                        ref,
                        item,
                        queueItems: uploadedTracks,
                      );
                    },
                  ),
                  ProfilePlaylistsSection(
                    isCurrentUser: true,
                    ownerName: profile?.displayName ?? profile?.userName,
                  ),
                  ProfilePlaylistsSection(
                    isCurrentUser: true,
                    ownerName: profile?.displayName ?? profile?.userName,
                    collectionType: CollectionType.album,
                    title: 'Albums',
                  ),
                  const ProfileLikesSection(),
                  const ProfileRepostsSection(),
                ],
              ),
            ),
          ),
    );
  }
}
