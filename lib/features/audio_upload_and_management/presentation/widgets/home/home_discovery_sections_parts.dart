part of 'home_discovery_sections.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.topPadding,
  });

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPadding, 18, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
