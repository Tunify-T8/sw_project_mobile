part of 'track_info_screen.dart';

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
