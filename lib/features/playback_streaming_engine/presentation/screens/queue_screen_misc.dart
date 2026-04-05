part of 'queue_screen.dart';

class _EmptyNextHint extends StatelessWidget {
  const _EmptyNextHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        'No tracks queued up',
        style: TextStyle(color: Colors.white38, fontSize: 14),
      ),
    );
  }
}
