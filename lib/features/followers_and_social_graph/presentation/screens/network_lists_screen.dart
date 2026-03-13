import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_lists_provider.dart';
import '../widgets/user_social_tile.dart';

class NetworkListsScreen extends ConsumerStatefulWidget {
  const NetworkListsScreen({super.key});

  @override
  ConsumerState<NetworkListsScreen> createState() => _NetworkListsScreenState();
}

class _NetworkListsScreenState extends ConsumerState<NetworkListsScreen> {
  final userID = "u1";
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(networkListsProvider.notifier).loadFollowersList(userID: userID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(networkListsProvider);
    final userList = listsState.followersUsers;
    bool isLoading;
    String error;

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text('Following', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: ListView.builder(
              itemCount: userList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Container(
                      child: Text(
                        "See Friends",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                final socialUser = userList[index - 1];
                return UserSocialTile(
                  displayName: socialUser.userDisplayName,
                  followersCount: socialUser.followersCount,
                  avatarUrl: socialUser.avatarUrl,
                  isFollowing: socialUser.isFollowing,
                  isNotificationEnabled: socialUser.isNotificationEnabled,
                );
              },
            ),
          ),

          Expanded(
            child: Container(
              child: Text("Bottom Bar", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
