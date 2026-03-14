import 'package:flutter/material.dart';
import '../widgets/library_menu_tile.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text("Library", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              //navigate
            },
            icon: Icon(Icons.settings),
            iconSize: 30.0,
            color: Colors.white,
          ),
          GestureDetector(
            onTap: () {
              //navigate
              print("user");
            },
            child: CircleAvatar(
              radius: 19.0,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=1"),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          LibraryMenuTile(label: "Your likes", onTap: () {}),
          LibraryMenuTile(label: "Playlists", onTap: () {}),
          LibraryMenuTile(label: "Albums", onTap: () {}),
          LibraryMenuTile(label: "Following", onTap: () {}),
          LibraryMenuTile(label: "Stations", onTap: () {}),
          LibraryMenuTile(label: "Your insights", onTap: () {}),
          LibraryMenuTile(label: "Your uploads", onTap: () {}),
        ],
      ),
    );
  }
}
