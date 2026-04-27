part of 'player_screen.dart';

class _BlockedWithNav extends StatelessWidget {
  const _BlockedWithNav({this.blockedReason});

  final BlockedReason? blockedReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlockedTrackView(blockedReason: blockedReason),
    );
  }
}

class _PlayerLoading extends StatelessWidget {
  const _PlayerLoading({this.title, this.artist, this.coverUrl});

  final String? title;
  final String? artist;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred artwork background (or solid dark if no cover yet)
        if (coverUrl != null && coverUrl!.isNotEmpty)
          _BlurredBackground(coverUrl: coverUrl!)
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A2E), Color(0xFF0D0D0D)],
              ),
            ),
          ),
        // Dark scrim
        Container(color: Colors.black.withValues(alpha: 0.52)),
        // Spinner + track info
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back button to allow dismissal during load
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              const Spacer(),
              _SpinningVinyl(coverUrl: coverUrl),
              const SizedBox(height: 32),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (artist != null) ...[
                const SizedBox(height: 6),
                Text(
                  artist!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              _PulsingDots(),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Artwork thumbnail with a spinning outer ring.
class _SpinningVinyl extends StatefulWidget {
  const _SpinningVinyl({this.coverUrl});
  final String? coverUrl;

  @override
  State<_SpinningVinyl> createState() => _SpinningVinylState();
}

class _SpinningVinylState extends State<_SpinningVinyl>
    with SingleTickerProviderStateMixin {
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double outerSize = 170;
    const double innerSize = 118;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Spinning orange arc ring
          RotationTransition(
            turns: _spin,
            child: SizedBox(
              width: outerSize,
              height: outerSize,
              child: CircularProgressIndicator(
                value: 0.78,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
          ),
          // Artwork circle
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: widget.coverUrl != null && widget.coverUrl!.isNotEmpty
                  ? Image.network(
                      widget.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, trace) => const Icon(
                        Icons.music_note,
                        color: Colors.white24,
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.music_note,
                      color: Colors.white24,
                      size: 40,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three dots that pulse in sequence.
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_ctrl.value * 3 - i) % 3 + 3) % 3;
            final opacity = t < 1 ? t : (t < 2 ? 2 - t : 0.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: 0.25 + opacity.clamp(0.0, 1.0) * 0.75,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Lightweight buffering spinner shown over the loaded player content.
class _BufferingOverlay extends StatelessWidget {
  const _BufferingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.38),
          child: const Center(
            child: SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.8,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 52),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerEmpty extends StatelessWidget {
  const _PlayerEmpty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text(
              'No track loaded',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
