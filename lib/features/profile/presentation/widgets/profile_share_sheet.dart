import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileShareSheet {
  final BuildContext context;
  final String userName;
  final String bio;
  final int followersCount;
  final int tracksCount;
  final File? profileImage;
  final String? profileImagePath;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? spotify;
  final String? tiktok;
  final String? soundcloud;
  final TextStyle bioStyle;

  ProfileShareSheet({
    required this.context,
    required this.userName,
    required this.bio,
    required this.followersCount,
    required this.tracksCount,
    required this.profileImage,
    required this.profileImagePath,
    required this.instagram,
    required this.twitter,
    this.youtube,
    this.spotify,
    this.tiktok,
    this.soundcloud,
    required this.bioStyle,
  });

  bool get _hasRemoteProfileImage =>
      profileImagePath != null && profileImagePath!.trim().startsWith('http');

  bool get _hasLocalProfileImage =>
      profileImagePath != null &&
      profileImagePath!.trim().isNotEmpty &&
      File(profileImagePath!).existsSync();

  Widget _buildSocialLinks() {
    final links = [
      if (instagram != null && instagram!.isNotEmpty)
        {'icon': FontAwesomeIcons.instagram, 'url': instagram!, 'label': instagram!},
      if (twitter != null && twitter!.isNotEmpty)
        {'icon': FontAwesomeIcons.xTwitter, 'url': twitter!, 'label': twitter!},
      if (youtube != null && youtube!.isNotEmpty)
        {'icon': FontAwesomeIcons.youtube, 'url': youtube!, 'label': youtube!},
      if (spotify != null && spotify!.isNotEmpty)
        {'icon': FontAwesomeIcons.spotify, 'url': spotify!, 'label': spotify!},
      if (tiktok != null && tiktok!.isNotEmpty)
        {'icon': FontAwesomeIcons.tiktok, 'url': tiktok!, 'label': tiktok!},
      if (soundcloud != null && soundcloud!.isNotEmpty)
        {'icon': FontAwesomeIcons.soundcloud, 'url': soundcloud!, 'label': soundcloud!},
    ];

    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: links
            .map(
              (link) => GestureDetector(
                onTap: () async {
                  final url = Uri.parse(link['url'] as String);
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      FaIcon(
                        link['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          link['label'] as String,
                          style: bioStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void show() {
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
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : _hasLocalProfileImage
                          ? FileImage(File(profileImagePath!))
                          : _hasRemoteProfileImage
                              ? NetworkImage(profileImagePath!)
                              : null,
                  child: profileImage == null &&
                          !_hasLocalProfileImage &&
                          !_hasRemoteProfileImage
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$followersCount Followers · $tracksCount Tracks',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  buildShareAction(Icons.send, 'Message'),
                  buildShareAction(
                    Icons.copy,
                    'Copy Link',
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                            text: 'https://soundcloud.com/$userName'),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  buildShareAction(FontAwesomeIcons.whatsapp, 'WhatsApp'),
                  buildShareAction(Icons.message, 'SMS'),
                  buildShareAction(FontAwesomeIcons.facebookMessenger, 'Messenger'),
                  buildShareAction(FontAwesomeIcons.instagram, 'Instagram'),
                  buildShareAction(FontAwesomeIcons.facebook, 'Facebook'),
                  buildShareAction(Icons.more_horiz, 'More'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.radio, color: Colors.white),
              title: const Text(
                'Start station',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text(
                'View info',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showInfoSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShareAction(IconData icon, String label, {VoidCallback? onTap}) =>
      SizedBox(
        width: 80,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: Colors.white, size: 24),
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

  void showInfoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Info',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bio',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bio,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'Links',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 8),
            _buildSocialLinks(),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}