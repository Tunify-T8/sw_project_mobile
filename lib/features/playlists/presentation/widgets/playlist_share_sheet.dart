import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/collection_privacy.dart';
import '../../domain/entities/playlist_summary_entity.dart';
import '../providers/playlist_providers.dart';

void showPlaylistShareSheet({
  required BuildContext context,
  required PlaylistSummaryEntity playlist,
  String? secretToken,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlaylistShareSheet(
      playlist: playlist,
      secretToken: secretToken,
    ),
  );
}

class _PlaylistShareSheet extends ConsumerStatefulWidget {
  const _PlaylistShareSheet({required this.playlist, this.secretToken});

  final PlaylistSummaryEntity playlist;
  final String? secretToken;

  @override
  ConsumerState<_PlaylistShareSheet> createState() => _PlaylistShareSheetState();
}

class _PlaylistShareSheetState extends ConsumerState<_PlaylistShareSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late Future<String> _shareUrlFuture;
  late Future<String> _embedCodeFuture;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _shareUrlFuture = ref.read(playlistRepositoryProvider).getShareUrl(
          widget.playlist.id,
        );
    _embedCodeFuture = ref.read(playlistRepositoryProvider).getEmbedCode(
          widget.playlist.id,
        );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      height: MediaQuery.of(context).size.height * 0.68,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _MiniPreview(playlist: widget.playlist),
          const SizedBox(height: 4),
          TabBar(
            controller: _tabCtrl,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Share'),
              Tab(text: 'Embed'),
              Tab(text: 'Message'),
            ],
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _ShareTab(
                  playlist: widget.playlist,
                  shareUrlFuture: _shareUrlFuture,
                ),
                _EmbedTab(
                  playlist: widget.playlist,
                  embedCodeFuture: _embedCodeFuture,
                ),
                _MessageTab(
                  playlist: widget.playlist,
                  shareUrlFuture: _shareUrlFuture,
                ),
              ],
            ),
          ),
          SizedBox(height: bottom),
        ],
      ),
    );
  }
}

class _MiniPreview extends StatelessWidget {
  const _MiniPreview({required this.playlist});
  final PlaylistSummaryEntity playlist;

  @override
  Widget build(BuildContext context) {
    final privacyLabel = playlist.privacy == CollectionPrivacy.private
        ? 'Private'
        : 'Public';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
            ),
            clipBehavior: Clip.antiAlias,
            child: playlist.coverUrl != null
                ? Image.network(playlist.coverUrl!, fit: BoxFit.cover)
                : const Icon(Icons.queue_music, color: Colors.white38, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Playlist',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '·',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      playlist.privacy == CollectionPrivacy.private
                          ? Icons.lock_rounded
                          : Icons.public,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      privacyLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTab extends StatefulWidget {
  const _ShareTab({
    required this.playlist,
    required this.shareUrlFuture,
  });

  final PlaylistSummaryEntity playlist;
  final Future<String> shareUrlFuture;

  @override
  State<_ShareTab> createState() => _ShareTabState();
}

class _ShareTabState extends State<_ShareTab> {
  bool _copied = false;

  void _copyLink(String shareUrl) {
    Clipboard.setData(ClipboardData(text: shareUrl));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: widget.shareUrlFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to generate URL.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final shareUrl = snapshot.data!;
        final title = Uri.encodeComponent(
          'Check out "${widget.playlist.title}" on Tunify: $shareUrl',
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialBtn(
                    faIcon: FontAwesomeIcons.xTwitter,
                    color: Colors.white,
                    bgColor: Colors.black,
                    label: 'X',
                    onTap: () async => launchUrl(
                      Uri.parse('https://twitter.com/intent/tweet?text=$title'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  _SocialBtn(
                    faIcon: FontAwesomeIcons.facebook,
                    color: Colors.white,
                    bgColor: const Color(0xFF1877F2),
                    label: 'Facebook',
                    onTap: () async => launchUrl(
                      Uri.parse(
                        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  _SocialBtn(
                    faIcon: FontAwesomeIcons.whatsapp,
                    color: Colors.white,
                    bgColor: const Color(0xFF25D366),
                    label: 'WhatsApp',
                    onTap: () async => launchUrl(
                      Uri.parse('https://wa.me/?text=$title'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  _SocialBtn(
                    faIcon: FontAwesomeIcons.instagram,
                    color: Colors.white,
                    bgColor: const Color(0xFFE1306C),
                    label: 'Instagram',
                    onTap: () async => launchUrl(
                      Uri.parse(
                        'instagram://sharesheet?text=${Uri.encodeComponent(shareUrl)}',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  _SocialBtn(
                    faIcon: FontAwesomeIcons.snapchat,
                    color: Colors.black,
                    bgColor: const Color(0xFFFFFC00),
                    label: 'Snapchat',
                    onTap: () async => launchUrl(
                      Uri.parse(
                        'snapchat://send?text=${Uri.encodeComponent(shareUrl)}',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shareUrl,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _copied ? null : () => _copyLink(shareUrl),
                      child: Text(
                        _copied ? 'Copied!' : 'Copy',
                        style: TextStyle(
                          color: _copied
                              ? Colors.green
                              : Colors.orangeAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmbedTab extends StatelessWidget {
  const _EmbedTab({
    required this.playlist,
    required this.embedCodeFuture,
  });
  final PlaylistSummaryEntity playlist;
  final Future<String> embedCodeFuture;

  @override
  Widget build(BuildContext context) {
    if (playlist.privacy == CollectionPrivacy.private) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, color: Colors.white38, size: 40),
              SizedBox(height: 12),
              Text(
                'Make this playlist public\nto get an embed code.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<String>(
      future: embedCodeFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Could not load embed code.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final code = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste this code into your website.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text(
                    'Copy code',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF1C1C1E),
                        content: Text(
                          'Embed code copied',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageTab extends StatelessWidget {
  const _MessageTab({
    required this.playlist,
    required this.shareUrlFuture,
  });

  final PlaylistSummaryEntity playlist;
  final Future<String> shareUrlFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: shareUrlFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to generate URL.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final shareUrl = snapshot.data!;
        final body = Uri.encodeComponent(
          'Check out "${playlist.title}" on Tunify: $shareUrl',
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialBtn(
                faIcon: FontAwesomeIcons.whatsapp,
                color: Colors.white,
                bgColor: const Color(0xFF25D366),
                label: 'WhatsApp',
                onTap: () async => launchUrl(
                  Uri.parse('https://wa.me/?text=$body'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SocialBtn(
                icon: Icons.sms_outlined,
                color: Colors.white,
                bgColor: const Color(0xFF2A2A2A),
                label: 'SMS',
                onTap: () async => launchUrl(
                  Uri.parse('sms:?body=$body'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SocialBtn(
                icon: Icons.mail_outline,
                color: Colors.white,
                bgColor: const Color(0xFF2A2A2A),
                label: 'Email',
                onTap: () async => launchUrl(
                  Uri.parse(
                    'mailto:?subject=${Uri.encodeComponent(playlist.title)}&body=$body',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _SocialBtn(
                icon: Icons.more_horiz,
                color: Colors.white,
                bgColor: const Color(0xFF2A2A2A),
                label: 'More',
                onTap: () async => launchUrl(
                  Uri.parse(shareUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({
    this.faIcon,
    this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
    required this.onTap,
  }) : assert(faIcon != null || icon != null);

  final IconData? faIcon;
  final IconData? icon;
  final Color color;
  final Color bgColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: faIcon != null
                  ? Icon(faIcon, color: color, size: 22)
                  : Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
