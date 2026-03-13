import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_lists_provider.dart';
import '../widgets/user_social_tile.dart';
import '../../domain/entities/network_list_type.dart';

class NetworkListsScreen extends ConsumerStatefulWidget {
  final NetworkListType listType;
  final String userID;

  const NetworkListsScreen({
    super.key,
    required this.listType,
    required this.userID,
  });

  @override
  ConsumerState<NetworkListsScreen> createState() => _NetworkListsScreenState();
}

class _NetworkListsScreenState extends ConsumerState<NetworkListsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.listType == NetworkListType.followers) {
        ref
            .read(networkListsProvider.notifier)
            .loadFollowersList(userID: widget.userID);
      } else {
        ref
            .read(networkListsProvider.notifier)
            .loadFollowingList(userID: widget.userID);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(networkListsProvider);

    final userList;
    if (widget.listType == NetworkListType.followers)
      userList = listsState.followersUsers;
    else
      userList = listsState.followingUsers;


    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text(
          widget.listType == NetworkListType.followers
              ? 'Followers'
              : 'Following',
          style: TextStyle(color: Colors.white),
        ),
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
                  listType: widget.listType,
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
