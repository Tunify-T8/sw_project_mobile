import 'package:flutter/material.dart';
import '../../../../core/design_system/colors.dart';

/// Central transport controls: shuffle, previous, play/pause, next, repeat.
class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.hasQueue,
    required this.onPlay,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    this.onShuffle,
    this.onRepeat,
    this.isShuffle = false,
    this.repeatMode = 0, // 0=none, 1=one, 2=all
  });

  final bool isPlaying;
  final bool hasQueue;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;
  final bool isShuffle;
  final int repeatMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Shuffle
        IconButton(
          icon: const Icon(Icons.shuffle, size: 22),
          color: isShuffle ? AppColors.primary : Colors.white54,
          onPressed: onShuffle ?? () {},
        ),

        // Previous
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 38),
          color: hasQueue ? Colors.white : Colors.white30,
          onPressed: hasQueue ? onPrevious : null,
          padding: EdgeInsets.zero,
        ),

        // Play / pause — large circle button
        _PlayButton(
          isPlaying: isPlaying,
          onPlay: onPlay,
          onPause: onPause,
        ),

        // Next
        IconButton(
          icon: const Icon(Icons.skip_next, size: 38),
          color: hasQueue ? Colors.white : Colors.white30,
          onPressed: hasQueue ? onNext : null,
          padding: EdgeInsets.zero,
        ),

        // Repeat
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                repeatMode == 1 ? Icons.repeat_one : Icons.repeat,
                size: 22,
              ),
              color: repeatMode > 0 ? AppColors.primary : Colors.white54,
              onPressed: onRepeat ?? () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayButton extends StatefulWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
  });

  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.reverse().then((_) => _controller.forward());
    if (widget.isPlaying) {
      widget.onPause();
    } else {
      widget.onPlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              widget.isPlaying ? Icons.pause : Icons.play_arrow,
              key: ValueKey(widget.isPlaying),
              color: Colors.black,
              size: 38,
            ),
          ),
        ),
      ),
    );
  }
}
