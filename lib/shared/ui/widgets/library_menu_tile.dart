import 'package:flutter/material.dart';

class LibraryMenuTile extends StatelessWidget {
   final String label;
  final Function() onTap; //maybe change this to just the page?

  LibraryMenuTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
            title: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 18.0),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 30.0,
            ),
            onTap: onTap,
          );
  }
}