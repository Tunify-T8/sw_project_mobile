import 'package:flutter/material.dart';

class NetworkListsTrueFriendsTile extends StatelessWidget {
  final VoidCallback onTap;

  const NetworkListsTrueFriendsTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        key: const Key('true_friends_tile'),
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2A2A2A),
          child: Icon(Icons.people),
        ),
        title: const Text(
          'People who follow you back',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'See your true friends',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        tileColor: const Color(0xFF18181A),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white,
          size: 28.0,
        ),
      ),
    );
  }
}
