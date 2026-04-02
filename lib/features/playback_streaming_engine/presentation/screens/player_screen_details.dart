part of 'player_screen.dart';

class _TrackInfo extends StatelessWidget {
  const _TrackInfo({
    required this.title,
    required this.artistName,
    required this.isLiked,
    required this.onLike,
  });

  final String title;
  final String artistName;
  final bool isLiked;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                artistName,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onLike,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isLiked),
              color: isLiked ? AppColors.primary : Colors.white54,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.positionSeconds,
    required this.durationSeconds,
    required this.isPreviewOnly,
  });

  final double positionSeconds;
  final double durationSeconds;
  final bool isPreviewOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _fmt(positionSeconds),
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        if (isPreviewOnly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: const Text(
              'PREVIEW',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        Text(
          _fmt(durationSeconds),
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  String _fmt(double seconds) {
    final s = seconds.round();
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.volume,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onToggleMute,
  });

  final double volume;
  final bool isMuted;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggleMute,
          child: Icon(
            isMuted || volume == 0 ? Icons.volume_off : Icons.volume_down,
            color: Colors.white54,
            size: 20,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: isMuted ? 0 : volume,
              onChanged: onVolumeChanged,
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.white54, size: 20),
      ],
    );
  }
}
