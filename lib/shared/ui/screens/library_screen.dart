import 'package:flutter/material.dart';
import 'package:software_project/shared/ui/screens/settings_screen.dart';
import '../widgets/library_menu_tile.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //i think this should be seperated in a seperate folder
    final List<Map<String, dynamic>> libraryItems = [ 
      {
        'label': 'Your likes',
        'onTap': () {
          print('likes');
        },
      },
      {
        'label': 'Playlists',
        'onTap': () {
          print('playlists');
        },
      },
      {'label': 'Albums', 'onTap': () {}},
      {'label': 'Following', 'onTap': () {}},
      {'label': 'Stations', 'onTap': () {}},
      {'label': 'Your insights', 'onTap': () {}},
      {'label': 'Your uploads', 'onTap': () {}},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Library', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            color: Colors.white,
          ),
          GestureDetector(
            onTap: () {
              //navigate to profile
              print('go to user profile');
            },
            child: CircleAvatar(
              radius: 18.0,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: libraryItems.length,
        itemBuilder: (context, index) {
          final item = libraryItems[index];

          return LibraryMenuTile(label: item['label'], onTap: item['onTap']);
        },
      ),
    );
  }
}
