part of 'home_discovery_sections.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.topPadding,
    this.eyebrow,
  });

  final String title;
  final double topPadding;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPadding, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPickCard extends StatelessWidget {
  const _FeaturedPickCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 184,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF385E94), Color(0xFF5B4B7B)],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hot For You',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fresh recommendations based on what you have been playing lately.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 18),
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MadeForYouList extends StatelessWidget {
  const _MadeForYouList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 266,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 18),
        children: const [
          _MadeForYouCard(
            color: Color(0xFF2A4E72),
            label: 'More of what you like',
            sub: 'Tracks and artists you may want to keep on repeat.',
          ),
          SizedBox(width: 14),
          _MadeForYouCard(
            color: Color(0xFF5A1A2A),
            label: 'Late night picks',
            sub: 'A softer mix tailored to your recent mood.',
          ),
          SizedBox(width: 18),
        ],
      ),
    );
  }
}

class _MadeForYouCard extends StatelessWidget {
  const _MadeForYouCard({
    required this.color,
    required this.label,
    required this.sub,
  });

  final Color color;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 190,
            width: 220,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
