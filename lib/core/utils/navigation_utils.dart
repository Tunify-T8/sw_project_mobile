import 'package:flutter/material.dart';

import '../../../features/profile/presentation/screens/other_user_profile_screen.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';

void navigateToProfile(
  BuildContext context,
  String userId, {
  String? currentUserId,
}) {
  if (userId.isEmpty) return;
  if (currentUserId != null && userId == currentUserId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OtherUserProfileScreen(userId: userId)),
    );
  }
}