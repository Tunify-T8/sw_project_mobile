import 'comment_dto.dart';
import 'engagement_user_dto.dart';
import 'track_engagement_dto.dart';
import '../../domain/entities/liked_track_entity.dart'; // engagement addition

class EngagementMockDataDto {
  static const String viewerId = 'user_current_1';

  static final List<EngagementUserDto> users = <EngagementUserDto>[
    const EngagementUserDto(
      id: 'user_current_1',
      username: 'darine',
      avatarUrl: null,
    ),
    const EngagementUserDto(
      id: 'user_2',
      username: 'beatmaker_ali',
      avatarUrl: null,
    ),
    const EngagementUserDto(
      id: 'user_3',
      username: 'sara_mix',
      avatarUrl: null,
    ),
    const EngagementUserDto(
      id: 'user_4',
      username: 'omar.wav',
      avatarUrl: null,
    ),
    const EngagementUserDto(
      id: 'user_5',
      username: 'nour_lofi',
      avatarUrl: null,
    ),
  ];

  static final List<TrackEngagementDto> trackEngagements =
      <TrackEngagementDto>[
        const TrackEngagementDto(
          trackId: 't1',
          likeCount: 126,
          repostCount: 34,
          commentCount: 9,
          isLiked: true,
          isReposted: false,
        ),
        const TrackEngagementDto(
          trackId: 't2',
          likeCount: 52,
          repostCount: 12,
          commentCount: 5,
          isLiked: false,
          isReposted: false,
        ),
        const TrackEngagementDto(
          trackId: 't3',
          likeCount: 902,
          repostCount: 210,
          commentCount: 47,
          isLiked: true,
          isReposted: true,
        ),
      ];

  static final List<CommentDto> comments = <CommentDto>[
    CommentDto(
      id: 'comment_1',
      trackId: 't1',
      user: users[1],
      timestamp: 14,
      text: 'Kick is crazy here.',
      likesCount: 3,
      repliesCount: 1,
      createdAt: DateTime.parse('2026-03-20T09:00:00Z'),
    ),
    CommentDto(
      id: 'comment_2',
      trackId: 't1',
      user: users[2],
      timestamp: 47,
      text: 'That switch up is clean.',
      likesCount: 7,
      repliesCount: 0,
      createdAt: DateTime.parse('2026-03-20T09:03:00Z'),
    ),
    CommentDto(
      id: 'comment_3',
      trackId: 't2',
      user: users[1],
      timestamp: 18,
      text: 'The intro gives me chills every time.',
      likesCount: 4,
      repliesCount: 1,
      createdAt: DateTime.parse('2026-03-22T10:00:00Z'),
    ),
    CommentDto(
      id: 'comment_4',
      trackId: 't2',
      user: users[2],
      timestamp: 45,
      text: 'That chord progression is insane.',
      likesCount: 9,
      repliesCount: 0,
      createdAt: DateTime.parse('2026-03-22T10:20:00Z'),
    ),
    CommentDto(
      id: 'comment_5',
      trackId: 't2',
      user: users[3],
      timestamp: 78,
      text: 'This is where the track really opens up.',
      likesCount: 6,
      repliesCount: 2,
      createdAt: DateTime.parse('2026-03-22T11:00:00Z'),
    ),
    CommentDto(
      id: 'comment_6',
      trackId: 't2',
      user: users[4],
      timestamp: 112,
      text: 'The build here never gets old.',
      likesCount: 3,
      repliesCount: 0,
      createdAt: DateTime.parse('2026-03-22T11:30:00Z'),
    ),
    CommentDto(
      id: 'comment_7',
      trackId: 't2',
      user: users[0],
      timestamp: 140,
      text: 'Outro is pure gold.',
      likesCount: 11,
      repliesCount: 1,
      createdAt: DateTime.parse('2026-03-22T12:00:00Z'),
    ),
    CommentDto(
      id: 'comment_8',
      trackId: 't3',
      user: users[3],
      timestamp: 91,
      text: 'Bass drop hit hard.',
      likesCount: 12,
      repliesCount: 2,
      createdAt: DateTime.parse('2026-03-21T10:15:00Z'),
    ),
  ];

  static final Map<String, List<String>> trackLikers = <String, List<String>>{
    't1': <String>['user_current_1', 'user_2', 'user_3', 'user_4'],
    't2': <String>['user_2', 'user_5'],
    't3': <String>[
      'user_current_1',
      'user_2',
      'user_3',
      'user_4',
      'user_5',
    ],
  };

  // engagement addition — mock response for GET /users/me/likes
  // replace this list with a real API call when BE is ready
  static final List<LikedTrackEntity> likedTracks = [
    LikedTrackEntity(
      trackId: 't1',
      title: 'Midnight Drive',
      artistId: 'a1',
      artistName: 'Drake',
      artistAvatar: 'https://i.pravatar.cc/150?img=1',
      artistVerified: true,
      coverUrl: 'https://picsum.photos/400/400?random=1',
      duration: 215,
      likesCount: 320,
      commentsCount: 45,
      likedAt: DateTime.parse('2026-03-18T10:00:00Z'),
    ),
    LikedTrackEntity(
      trackId: 't3',
      title: 'Astro Vibes',
      artistId: 'a3',
      artistName: 'Travis Scott',
      artistAvatar: 'https://i.pravatar.cc/150?img=4',
      artistVerified: true,
      coverUrl: 'https://picsum.photos/400/400?random=3',
      duration: 230,
      likesCount: 900,
      commentsCount: 120,
      likedAt: DateTime.parse('2026-03-19T14:30:00Z'),
    ),
  ];

  static final Map<String, List<String>> trackReposters =
      <String, List<String>>{
        't1': <String>['user_2', 'user_4'],
        't2': <String>['user_5'],
        't3': <String>['user_current_1', 'user_3', 'user_4'],
      };
}
