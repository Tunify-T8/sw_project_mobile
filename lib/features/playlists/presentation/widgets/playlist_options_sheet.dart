import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../../../audio_upload_and_management/presentation/widgets/your_uploads/your_uploads_options_actions.dart';

void showPlaylistOptionsSheet({
  required BuildContext context,
  required PlaylistSummaryEntity playlist,
  required VoidCallback onEdit,
  required VoidCallback onTogglePrivacy,
  required VoidCallback onAddMusic,
  required VoidCallback onDelete,
  // Extra rows shown only when opened from the detail screen
  bool isDetailView = false,
  VoidCallback? onCopyPlaylist,
  VoidCallback? onShufflePlay,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlaylistOptionsSheet(
      playlist: playlist,
      onEdit: onEdit,
      onTogglePrivacy: onTogglePrivacy,
      onAddMusic: onAddMusic,
      onDelete: onDelete,
      isDetailView: isDetailView,
      onCopyPlaylist: onCopyPlaylist,
      onShufflePlay: onShufflePlay,
    ),
  );
}

class _PlaylistOptionsSheet extends StatelessWidget {
  const _PlaylistOptionsSheet({
    required this.playlist,
    required this.onEdit,
    required this.onTogglePrivacy,
    required this.onAddMusic,
    required this.onDelete,
    this.isDetailView = false,
    this.onCopyPlaylist,
    this.onShufflePlay,
  });

  final PlaylistSummaryEntity playlist;
  final VoidCallback onEdit;
  final VoidCallback onTogglePrivacy;
  final VoidCallback onAddMusic;
  final VoidCallback onDelete;
  final bool isDetailView;
  final VoidCallback? onCopyPlaylist;
  final VoidCallback? onShufflePlay;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _DragHandle(),
          _Header(playlist: playlist),
          _ShareRow(playlist: playlist),
          const Divider(color: Colors.white12, height: 1),
          _OptionRow(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          _OptionRow(
            icon: playlist.privacy == CollectionPrivacy.private
                ? Icons.lock_open_outlined
                : Icons.lock_outline,
            label: playlist.privacy == CollectionPrivacy.private
                ? 'Make public'
                : 'Make private',
            onTap: () {
              Navigator.pop(context);
              onTogglePrivacy();
            },
          ),
          _OptionRow(
            icon: Icons.library_add_outlined,
            label: 'Add music',
            onTap: () {
              Navigator.pop(context);
              onAddMusic();
            },
          ),
          _OptionRow(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context);
            },
          ),
          if (isDetailView)
            _OptionRow(
              icon: Icons.copy_outlined,
              label: 'Copy playlist',
              onTap: () {
                Navigator.pop(context);
                onCopyPlaylist?.call();
              },
            ),
          const Divider(color: Colors.white12, height: 1),
          _OptionRow(
            icon: Icons.queue_play_next_outlined,
            label: 'Play Next',
            onTap: () => Navigator.pop(context),
          ),
          _OptionRow(
            icon: Icons.add_to_queue_outlined,
            label: 'Play Last',
            onTap: () => Navigator.pop(context),
          ),
          if (isDetailView)
            _OptionRow(
              icon: Icons.shuffle,
              label: 'Shuffle play',
              onTap: () {
                Navigator.pop(context);
                onShufflePlay?.call();
              },
            ),
          SizedBox(height: bottomPadding + 8),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Delete playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete "${playlist.title}"? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.playlist});
  final PlaylistSummaryEntity playlist;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (playlist.coverUrl != null)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Image.network(playlist.coverUrl!, fit: BoxFit.cover),
            ),
          ),
        Container(color: Colors.black.withValues(alpha: 0.6)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              _CoverArt(coverUrl: playlist.coverUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.privacy == CollectionPrivacy.private
                          ? 'Private playlist'
                          : 'Public playlist',
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({this.coverUrl});
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null
          ? Image.network(coverUrl!, fit: BoxFit.cover)
          : const Icon(Icons.queue_music, color: Colors.white38, size: 32),
    );
  }
}

// ─── Share row ────────────────────────────────────────────────────────────────

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.playlist});
  final PlaylistSummaryEntity playlist;

  String get _shareUrl =>
      '${ApiEndpoints.shareBaseUrl}/playlists/${playlist.id}';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          YourUploadsShareButton(
            icon: Icons.send_outlined,
            label: 'Message',
            onTap: () async {
              final text = Uri.encodeComponent(
                  'Check out "${playlist.title}" on Tunify: $_shareUrl');
              await launchUrl(Uri.parse('sms:?body=$text'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          YourUploadsShareButton(
            icon: Icons.copy_outlined,
            label: 'Copy link',
            onTap: () => _copyLink(context),
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.whatsapp,
            iconColor: const Color(0xFF25D366),
            label: 'WhatsApp',
            onTap: () async {
              final msg = Uri.encodeComponent(
                  'Check out "${playlist.title}" on Tunify: $_shareUrl');
              await launchUrl(Uri.parse('https://wa.me/?text=$msg'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.instagram,
            iconColor: const Color(0xFFE1306C),
            label: 'Stories',
            onTap: () async {
              await launchUrl(
                Uri.parse(
                    'instagram://sharesheet?text=${Uri.encodeComponent(_shareUrl)}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.snapchat,
            iconColor: const Color(0xFFFFFC00),
            label: 'Snapchat',
            onTap: () async {
              await launchUrl(
                Uri.parse(
                    'snapchat://send?text=${Uri.encodeComponent(_shareUrl)}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          YourUploadsShareButton(
            icon: Icons.sms_outlined,
            label: 'SMS',
            onTap: () async {
              final text = Uri.encodeComponent(
                  'Check out "${playlist.title}" on Tunify: $_shareUrl');
              await launchUrl(Uri.parse('sms:?body=$text'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.facebook,
            iconColor: const Color(0xFF1877F2),
            label: 'Facebook',
            onTap: () async {
              await launchUrl(
                Uri.parse(
                    'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(_shareUrl)}'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SocialShareButton(
            faIcon: FontAwesomeIcons.xTwitter,
            iconColor: Colors.white,
            label: 'X',
            onTap: () async {
              final text = Uri.encodeComponent(
                  'Check out "${playlist.title}" on Tunify: $_shareUrl');
              await launchUrl(
                  Uri.parse('https://twitter.com/intent/tweet?text=$text'),
                  mode: LaunchMode.externalApplication);
            },
          ),
          YourUploadsShareButton(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: () async {
              await launchUrl(Uri.parse(_shareUrl),
                  mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _shareUrl));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1C1C1E),
        content: Text('Link copied', style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ─── Option row ───────────────────────────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 16)),
      dense: true,
    );
  }
}

// ─── Drag handle ──────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
