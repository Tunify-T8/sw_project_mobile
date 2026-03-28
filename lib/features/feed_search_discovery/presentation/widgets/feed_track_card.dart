import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class FeedTrackCard extends StatelessWidget {
  const FeedTrackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12.0, 55.0, 12.0, 20.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_horiz),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ],
                ),

                SizedBox(height: 120),

                Center(
                  child: Container(
                    width: 215.0,
                    height: 215.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://i1.sndcdn.com/artworks-000150361526-unu99x-t500x500.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.favorite_border),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        Text(
                          '12k',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: Icon(Icons.comment),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        Text(
                          '40',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.more),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 10.0,
                      backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAkRMD5U8f7MsLHa0hEtm3bbRQfeLXR8zr-g&s',
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'Cairokee posted a track · 4:47',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '· 10y ago',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),

                SizedBox(height: 5.0),

                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF464646),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akher Oghneya - آخر أغنية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20.0,
                                backgroundImage: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAkRMD5U8f7MsLHa0hEtm3bbRQfeLXR8zr-g&s',
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                'Cairokee',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20.0,
                              ),
                              SizedBox(width: 8.0),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF605E5F),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Following',
                                  style: const TextStyle(fontSize: 15.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          left: 12.0,
          top: 55.0,
          right: 12.0,
          bottom: 20.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Color(0x70494949),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Tap to Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 23.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
