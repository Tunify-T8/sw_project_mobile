import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/library_menu_tile.dart';
import 'library_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 30.0),
        ),
      ),
      body: ListView(
        children: [
          LibraryMenuTile(label: "Import my music", onTap: () {}),
          LibraryMenuTile(label: "Account", onTap: () {}),
          LibraryMenuTile(label: "Inbox", onTap: () {}),
          LibraryMenuTile(label: "Social", onTap: () {}),
          LibraryMenuTile(label: "Notifications", onTap: () {}),
          LibraryMenuTile(label: "App Icon", onTap: () {}),
          LibraryMenuTile(label: "App Language", onTap: () {}),
          LibraryMenuTile(label: "Storage", onTap: () {}),
          SizedBox(height: 20.0),
          LibraryMenuTile(label: "Analytics", onTap: () {}),
          LibraryMenuTile(label: "Communications", onTap: () {}),
          LibraryMenuTile(label: "Advertising", onTap: () {}),
          LibraryMenuTile(label: "Tell a friend", onTap: () {}),
          SizedBox(height: 20.0),
          LibraryMenuTile(label: "Troubleshooting", onTap: () {}),
          LibraryMenuTile(label: "Contact Support", onTap: () {}),
          LibraryMenuTile(label: "Legal", onTap: () {}),

          Padding(
            padding: EdgeInsets.all(15.0),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF303030),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              child: Text(
                "Sign out",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
