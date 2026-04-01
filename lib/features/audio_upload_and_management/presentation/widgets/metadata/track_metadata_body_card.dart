part of 'track_metadata_body.dart';

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: child,
    );
  }
}
