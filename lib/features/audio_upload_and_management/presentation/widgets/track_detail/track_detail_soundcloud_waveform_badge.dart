part of 'track_detail_soundcloud_waveform.dart';

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.progress, required this.duration});

  final double progress;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final played = Duration(
      milliseconds: (duration.inMilliseconds * progress).round(),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.88),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatTrackDetailDuration(played),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              width: 1,
              height: 13,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              color: Colors.white24,
            ),
            Text(
              formatTrackDetailDuration(duration),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
