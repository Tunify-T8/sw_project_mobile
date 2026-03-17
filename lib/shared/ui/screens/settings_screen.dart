import 'package:flutter/material.dart';
import '../widgets/library_menu_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoplay = true;
  bool classicFeed = false;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> topSettings = [
      {'label': 'Import my music', 'onTap': () {}},
      {'label': 'Account', 'onTap': () {}},
      {'label': 'Inbox', 'onTap': () {}},
      {'label': 'Social', 'onTap': () {}},
      {'label': 'Notifications', 'onTap': () {}},
      {'label': 'App Icon', 'onTap': () {}},
      {'label': 'App Language', 'onTap': () {}},
      {'label': 'Storage', 'onTap': () {}},
    ];

    final List<Map<String, dynamic>> middleSettings = [
      {'label': 'Analytics', 'onTap': () {}},
      {'label': 'Communications', 'onTap': () {}},
      {'label': 'Advertising', 'onTap': () {}},
      {'label': 'Tell a friend', 'onTap': () {}},
    ];

    final List<Map<String, dynamic>> bottomSettings = [
      {'label': 'Troubleshooting', 'onTap': () {}},
      {'label': 'Contact support', 'onTap': () {}},
      {'label': 'Legal', 'onTap': () {}},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        ),
      ),
      body: ListView(
        children: [
          LibraryMenuTile(
            label: 'Autoplay related tracks',
            onTap: () {},
            trailing: Switch(
              value: autoplay,
              onChanged: (value) {
                setState(() => autoplay = value);
              },
              activeThumbColor: Color(0xFFFF5500),
            ),
          ),
          LibraryMenuTile(
            label: 'Use Classic feed',
            onTap: () {},
            trailing: Switch(
              value: classicFeed,
              onChanged: (value) {
                setState(() => classicFeed = value);
              },
              activeThumbColor: Color(0xFFFF5500),
            ),
          ),

          ...topSettings.map(
            (item) =>
                LibraryMenuTile(label: item['label'], onTap: item['onTap']),
          ),

          const SizedBox(height: 15),

          ...middleSettings.map(
            (item) =>
                LibraryMenuTile(label: item['label'], onTap: item['onTap']),
          ),

          const SizedBox(height: 15),

          ...bottomSettings.map(
            (item) =>
                LibraryMenuTile(label: item['label'], onTap: item['onTap']),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF303030),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
