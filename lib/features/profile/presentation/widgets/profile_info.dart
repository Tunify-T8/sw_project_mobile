import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String userName;
  final String city;
  final String country;
  final String bio;
  final int followersCount;
  final int followingCount;
  final TextStyle nameStyle;
  final TextStyle bioStyle;
  final TextStyle followerStyle;
  final VoidCallback onShowMore;
  final Widget actionButtons; // 3lshan n7ot el actions fel nos

  const ProfileInfo({
    super.key,
    required this.userName,
    required this.city,
    required this.country,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.nameStyle,
    required this.bioStyle,
    required this.followerStyle,
    required this.onShowMore,
    required this.actionButtons,
  });

    Widget buildName() => Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Text(userName,style:nameStyle),
  );
    Widget buildBio() => Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Text(bio,style:bioStyle),
  );
  Widget buildLocation() => Padding(
    padding: const EdgeInsets.only(left: 25),
    child: Text('📍$city, $country', style: bioStyle),
  );
  Widget buildFollowerCount() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: [
          GestureDetector(
            onTap:(){
              //Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowerScreen()));
            },
          child: Text('$followersCount Followers', style: followerStyle),
          ),
          Text('  ·  ', style: followerStyle),
          GestureDetector(
            onTap:(){
              //Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingScreen()));
            },
            child:Text('$followingCount Following', style: followerStyle),
          ),
        ],
      ),
    );
  }
      Widget buildShowMore() => Padding(
  padding: const EdgeInsets.only(left: 25),
  child: GestureDetector(
    onTap: () => onShowMore(),
    child: const Text(
      'Show more',
      style: TextStyle(color: Color(0xFF0066CC), fontSize: 14),
    ),
  ),
);
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildName(),
      const SizedBox(height: 18),
      buildLocation(),
      const SizedBox(height: 18),
      buildFollowerCount(),
      const SizedBox(height: 18),
      actionButtons,  // use it here
      const SizedBox(height: 18),
      buildBio(),
      const SizedBox(height: 18),
      buildShowMore(),
    ],
  );
}

}