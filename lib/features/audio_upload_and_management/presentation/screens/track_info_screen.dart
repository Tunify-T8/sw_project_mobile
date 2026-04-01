import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../playback_streaming_engine/presentation/providers/player_provider.dart';
import '../../../playback_streaming_engine/presentation/widgets/mini_player.dart';
import '../../domain/entities/upload_item.dart';
import '../providers/track_detail_item_provider.dart';
import '../utils/upload_player_launcher.dart';
import '../widgets/upload_artwork_view.dart';

class TrackInfoScreen extends ConsumerWidget {
  const TrackInfoScreen({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedItemAsync = ref.watch(trackDetailItemProvider(item));
    final resolvedItem = resolvedItemAsync.asData?.value ?? item;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(item: resolvedItem),
            ),
            SliverToBoxAdapter(
              child: _MainTrackCard(item: resolvedItem),
            ),
            SliverToBoxAdapter(
              child: _UploaderCard(item: resolvedItem),
            ),
            SliverToBoxAdapter(
              child: _FanLeaderboard(item: resolvedItem),
            ),
            SliverToBoxAdapter(
              child: _PlaylistsSection(item: resolvedItem),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 54),
        ],
      ),
    );
  }
}

class _MainTrackCard extends ConsumerWidget {
  const _MainTrackCard({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider).asData?.value;
    final isCurrentTrack = playerState?.bundle?.trackId == item.id;
    final isPlaying = isCurrentTrack && playerState?.isPlaying == true;
    final stats = _MockTrackStats.fromItem(item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnimatedTrackAvatar(item: item, isPlaying: isPlaying),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.profile),
                        child: Text(
                          item.artistDisplay,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\u25B6 ${stats.playCountText} · ${item.durationLabel} · ${stats.releaseDateText}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 26),
                child: GestureDetector(
                  onTap: () => toggleUploadItemPlayback(ref, item),
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _MetricIconText(
                icon: Icons.favorite_border,
                text: stats.likeCountText,
              ),
              const SizedBox(width: 28),
              _MetricIconText(
                icon: Icons.chat_bubble_outline,
                text: stats.commentCountText,
              ),
              const SizedBox(width: 28),
              _MetricIconText(
                icon: Icons.repeat,
                text: stats.repostCountText,
              ),
              const SizedBox(width: 28),
              const Icon(Icons.more_horiz, color: Colors.white70, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _buildTrackDescription(item),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Show more',
            style: TextStyle(
              color: Colors.blue.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _buildTrackDescription(UploadItem item) {
    final cleaned = item.description?.trim();
    if (cleaned != null && cleaned.isNotEmpty) {
      return cleaned;
    }

    return 'Lyrics: Ahmed Ali Mousa\n'
        'Composition: Sherif Tag\n'
        'Arrangement: Tarek Madkour\n\n'
        'Lyrics:';
  }
}

class _MetricIconText extends StatelessWidget {
  const _MetricIconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AnimatedTrackAvatar extends StatefulWidget {
  const _AnimatedTrackAvatar({required this.item, required this.isPlaying});

  final UploadItem item;
  final bool isPlaying;

  @override
  State<_AnimatedTrackAvatar> createState() => _AnimatedTrackAvatarState();
}

class _AnimatedTrackAvatarState extends State<_AnimatedTrackAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedTrackAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: UploadArtworkView(
              localPath: widget.item.localArtworkPath,
              remoteUrl: widget.item.artworkUrl,
              width: 168,
              height: 168,
              backgroundColor: const Color(0xFF232323),
              placeholder: Container(
                color: const Color(0xFF2A2A2A),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white24,
                  size: 44,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
          if (widget.isPlaying)
            _NowPlayingBars(controller: _controller)
          else
            const Text(
              '....',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
        ],
      ),
    );
  }
}

class _NowPlayingBars extends StatelessWidget {
  const _NowPlayingBars({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value * math.pi * 2;
        final heights = [
          18 + math.sin(t) * 5,
          34 + math.sin(t + 0.8) * 7,
          28 + math.sin(t + 1.4) * 6,
          38 + math.sin(t + 2.1) * 8,
        ];

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final height in heights)
              Container(
                width: 6,
                height: (height.clamp(14, 44) as num).toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UploaderCard extends StatelessWidget {
  const _UploaderCard({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5D6),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🎵',
                style: TextStyle(fontSize: 34),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.artistDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Egypt',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FanLeaderboard extends StatelessWidget {
  const _FanLeaderboard({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    final entries = _mockLeaderboard(item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Fan leaderboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.info_outline, color: Colors.white54, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: _TabPill(label: 'Top', selected: true)),
                      Expanded(child: _TabPill(label: 'First')),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Fans who have played this track the most.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 18),
                for (int i = 0; i < entries.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${i + 1}.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF303030),
                          child: Text(
                            entries[i].name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            entries[i].name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${entries[i].plays} plays',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: selected ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: selected ? Colors.white70 : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white54,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlaylistsSection extends StatelessWidget {
  const _PlaylistsSection({required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    final playlists = _mockPlaylists(item);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'In Playlists',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              padding: const EdgeInsets.only(right: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return SizedBox(
                  width: 210,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          width: 210,
                          height: 150,
                          child: index == 0 && (item.localArtworkPath != null || item.artworkUrl != null)
                              ? UploadArtworkView(
                                  localPath: item.localArtworkPath,
                                  remoteUrl: item.artworkUrl,
                                  width: 210,
                                  height: 150,
                                  borderRadius: BorderRadius.zero,
                                  placeholder: Container(color: playlist.color),
                                )
                              : Container(
                                  color: playlist.color,
                                  alignment: Alignment.center,
                                  child: Text(
                                    playlist.emoji,
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        playlist.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        playlist.owner,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MockTrackStats {
  const _MockTrackStats({
    required this.playCountText,
    required this.likeCountText,
    required this.commentCountText,
    required this.repostCountText,
    required this.releaseDateText,
  });

  final String playCountText;
  final String likeCountText;
  final String commentCountText;
  final String repostCountText;
  final String releaseDateText;

  factory _MockTrackStats.fromItem(UploadItem item) {
    final seed = item.id.hashCode.abs();
    final playCount = 450000 + (seed % 900000);
    final likes = 14000 + (seed % 22000);
    final comments = 70 + (seed % 300);
    final reposts = 40 + (seed % 220);
    final date = item.createdAt;

    return _MockTrackStats(
      playCountText: _compactNumber(playCount),
      likeCountText: _compactNumber(likes),
      commentCountText: '$comments',
      repostCountText: '$reposts',
      releaseDateText:
          '${date.day} ${_monthName(date.month)} ${date.year}',
    );
  }

  static String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[((month - 1).clamp(0, 11) as num).toInt()];
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({required this.name, required this.plays});

  final String name;
  final int plays;
}

List<_LeaderboardEntry> _mockLeaderboard(UploadItem item) {
  final seed = item.id.hashCode.abs();
  const names = [
    'Mody Mohamed',
    'Reham Kareem',
    'User 921620114',
    'Adam Sharif',
    'Abdalrahman Ahmed',
  ];

  return List.generate(names.length, (index) {
    final plays = 110 + ((seed + index * 29) % 140);
    return _LeaderboardEntry(name: names[index], plays: plays);
  });
}

class _PlaylistCardData {
  const _PlaylistCardData({
    required this.title,
    required this.owner,
    required this.emoji,
    required this.color,
  });

  final String title;
  final String owner;
  final String emoji;
  final Color color;
}

List<_PlaylistCardData> _mockPlaylists(UploadItem item) {
  final safeArtist = item.artistDisplay.split(',').first.trim();
  return const [
    _PlaylistCardData(
      title: 'Summer Nights',
      owner: 'Mosaab',
      emoji: '🌴',
      color: Color(0xFF6A4B2B),
    ),
    _PlaylistCardData(
      title: 'el lol',
      owner: 'Wilo Ellol',
      emoji: '🎤',
      color: Color(0xFF8B6B49),
    ),
    _PlaylistCardData(
      title: 'Arabic',
      owner: 'Mirzana',
      emoji: '🕯️',
      color: Color(0xFF3E2C23),
    ),
  ].map((playlist) {
    if (playlist.title == 'Summer Nights') {
      return _PlaylistCardData(
        title: item.title,
        owner: safeArtist.isEmpty ? playlist.owner : safeArtist,
        emoji: playlist.emoji,
        color: playlist.color,
      );
    }
    return playlist;
  }).toList();
}
