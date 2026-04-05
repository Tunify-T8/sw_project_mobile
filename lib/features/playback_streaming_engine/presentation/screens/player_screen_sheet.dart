part of 'player_screen.dart';

class _MoreSheet extends StatelessWidget {
  const _MoreSheet({required this.bundle, required this.onClose});

  final dynamic bundle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _SheetTile(
                  icon: Icons.person_add_outlined,
                  label: 'Go to artist profile',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.playlist_add,
                  label: 'Add to playlist',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.radio,
                  label: 'Start station',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.comment_outlined,
                  label: 'View comments',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.repeat,
                  label: 'Repost on SoundCloud',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.info_outline,
                  label: 'Behind this track',
                  onTap: onClose,
                ),
                _SheetTile(
                  icon: Icons.flag_outlined,
                  label: 'Report',
                  onTap: onClose,
                  danger: true,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red[400]! : Colors.white;
    return ListTile(
      leading: Icon(icon, color: color.withOpacity(0.8), size: 22),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      dense: true,
      onTap: onTap,
    );
  }
}
