import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../../domain/entities/upload_item.dart';
import '../providers/library_uploads_provider.dart';
import 'edit_track_screen.dart';

/// SoundCloud-style full-screen track player.
/// Matches screenshots exactly:
///  - Full-screen artwork (or gradient from artwork dominant color)
///  - Title/artist/Behind this track top-left overlay
///  - ↓ dismiss circle button top-right
///  - When playing: waveform fills bottom area (orange = played, white = unplayed)
///    with position/total labels, scrollable horizontally
///  - When paused: play + skip-next buttons centred over the artwork
///  - Thin progress bar below waveform
///  - Bottom bar: ♡ Share Queue ···
class TrackDetailScreen extends ConsumerStatefulWidget {
  const TrackDetailScreen({super.key, required this.item});
  final UploadItem item;

  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  late PlayerController _player;
  bool _prepared = false;
  bool _isPlaying = false;
  bool _hasError = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = PlayerController();
    _prepare();
  }

  Future<void> _prepare() async {
    final path = widget.item.localFilePath;
    if (path == null || !File(path).existsSync()) {
      setState(() => _hasError = true);
      return;
    }
    try {
      await _player.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 300,
        volume: 1.0,
      );

      // Listen to position updates
      _player.onCurrentDurationChanged.listen((ms) {
        if (mounted) {
          setState(() => _position = Duration(milliseconds: ms));
        }
      });
      _player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() =>
              _isPlaying = state == PlayerState.playing);
        }
      });

      // Get total duration
      _duration = Duration(milliseconds: _player.maxDuration);

      if (mounted) setState(() => _prepared = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pausePlayer();
    } else {
      await _player.startPlayer();
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _dominantColor() {
    // Use localArtworkPath dominant color approximation
    // SoundCloud uses the artwork's dominant color as background
    return const Color(0xFF3A5A8A); // default blue-grey when no artwork
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasArtwork = item.localArtworkPath != null &&
        File(item.localArtworkPath!).existsSync();
    final hasRemoteArtwork =
        item.artworkUrl != null && item.artworkUrl!.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen artwork background ──────────────────────────
          Positioned.fill(
            child: hasArtwork
                ? Image.file(File(item.localArtworkPath!),
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.15),
                    colorBlendMode: BlendMode.darken)
                : hasRemoteArtwork
                    ? Image.network(
                        item.artworkUrl!,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.15),
                        colorBlendMode: BlendMode.darken,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _dominantColor(),
                                _dominantColor().withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _dominantColor(),
                          _dominantColor().withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
          ),

          // ── Top overlay: title/artist, dismiss ──────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + artist + Behind this track
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(item.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          child: Text(item.artistDisplay,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq,
                                  color: Colors.white70, size: 14),
                              SizedBox(width: 4),
                              Text('Behind this track',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Queue icon (top right area) and dismiss
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.devices_other,
                            color: Colors.white70, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Paused: play + next buttons centred ─────────────────────
          if (!_isPlaying && _prepared)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.skip_next_rounded,
                          color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),

          // ── Loading/error ────────────────────────────────────────────
          if (!_prepared && !_hasError)
            const Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ),

          // ── Bottom: waveform + progress bar + action bar ─────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Waveform
                if (_prepared)
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          AudioFileWaveforms(
                            size: Size(
                                MediaQuery.of(context).size.width - 32, 100),
                            playerController: _player,
                            enableSeekGesture: true,
                            waveformType: WaveformType.fitWidth,
                            waveformData: const [],
                            playerWaveStyle: const PlayerWaveStyle(
                              fixedWaveColor: Colors.white,
                              liveWaveColor: Color(0xFFFF5500),
                              spacing: 4,
                              waveThickness: 3,
                              showSeekLine: false,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Position labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_fmt(_position),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Container(
                                  width: 1,
                                  height: 14,
                                  color: Colors.white38,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8)),
                              Text(_fmt(_duration),
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Thin progress line
                          LinearProgressIndicator(
                            value: _duration.inMilliseconds > 0
                                ? _position.inMilliseconds /
                                    _duration.inMilliseconds
                                : 0,
                            backgroundColor: Colors.white24,
                            color: const Color(0xFFFF5500),
                            minHeight: 2,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_hasError)
                  _MockWaveform(onTap: () {}),

                // Action bar: ♡ Share Queue ···
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ActionBtn(
                            icon: Icons.favorite_border,
                            onTap: () {}),
                        _ActionBtn(
                            icon: Icons.ios_share_outlined,
                            onTap: () {}),
                        _ActionBtn(
                            icon: Icons.playlist_play_rounded,
                            onTap: () {}),
                        _ActionBtn(
                            icon: Icons.more_horiz,
                            onTap: () =>
                                _showMoreSheet(context, item)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreSheet(BuildContext context, UploadItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: Colors.white),
              title: const Text('Edit track',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) => EditTrackScreen(item: item)))
                    .then((result) {
                  if (result == true) {
                    ref
                        .read(libraryUploadsProvider.notifier)
                        .refresh();
                  }
                });
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete track',
                  style:
                      TextStyle(color: Colors.redAccent, fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(libraryUploadsProvider.notifier)
                    .deleteTrack(item.id);
                if (mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: Colors.white, size: 26),
      );
}

class _MockWaveform extends StatelessWidget {
  const _MockWaveform({required this.onTap});
  final VoidCallback onTap;

  static const _bars = [
    0.2, 0.4, 0.7, 0.5, 0.3, 0.8, 0.6, 0.4, 0.2, 0.5,
    0.7, 0.3, 0.6, 0.4, 0.8, 0.5, 0.2, 0.7, 0.4, 0.3,
    0.6, 0.8, 0.5, 0.2, 0.4, 0.7, 0.3, 0.6, 0.5, 0.4,
    0.8, 0.2, 0.5, 0.7, 0.3, 0.4, 0.6, 0.5, 0.2, 0.8,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 100,
          child: CustomPaint(
              painter: _WaveformPainter(bars: _bars, progress: 0.25),
              size: Size(MediaQuery.of(context).size.width - 32, 100)),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.bars, required this.progress});
  final List<double> bars;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final playedPaint = Paint()
      ..color = const Color(0xFFFF5500)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    final unpPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final bw = size.width / bars.length;
    for (int i = 0; i < bars.length; i++) {
      final x = i * bw + bw / 2;
      final h = bars[i] * size.height * 0.85;
      final top = (size.height - h) / 2;
      final paint = (i / bars.length) < progress ? playedPaint : unpPaint;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress;
}
