import 'comment_dto.dart';
import 'engagement_user_dto.dart';
import 'track_engagement_dto.dart';

class EngagementMockDataDto {
  static const String viewerId = 'user_current_1';

  static final List<EngagementUserDto> users = <EngagementUserDto>[
    const EngagementUserDto(
      id: 'user_current_1',
      username: 'you',
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
          trackId: 'track_1',
          likeCount: 126,
          repostCount: 34,
          commentCount: 9,
          isLiked: true,
          isReposted: false,
        ),
        const TrackEngagementDto(
          trackId: 'track_2',
          likeCount: 52,
          repostCount: 12,
          commentCount: 5,
          isLiked: false,
          isReposted: false,
        ),
        const TrackEngagementDto(
          trackId: 'track_3',
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
      trackId: 'track_1',
      user: users[1],
      timestamp: 14,
      text: 'Kick is crazy here.',
      likesCount: 3,
      repliesCount: 1,
      createdAt: DateTime.parse('2026-03-20T09:00:00Z'),
    ),
    CommentDto(
      id: 'comment_2',
      trackId: 'track_1',
      user: users[2],
      timestamp: 47,
      text: 'That switch up is clean.',
      likesCount: 7,
      repliesCount: 0,
      createdAt: DateTime.parse('2026-03-20T09:03:00Z'),
    ),
    CommentDto(
      id: 'comment_3',
      trackId: 'track_3',
      user: users[3],
      timestamp: 91,
      text: 'Bass drop hit hard.',
      likesCount: 12,
      repliesCount: 2,
      createdAt: DateTime.parse('2026-03-21T10:15:00Z'),
    ),
  ];

  static final Map<String, List<String>> trackLikers = <String, List<String>>{
    'track_1': <String>['user_current_1', 'user_2', 'user_3', 'user_4'],
    'track_2': <String>['user_2', 'user_5'],
    'track_3': <String>[
      'user_current_1',
      'user_2',
      'user_3',
      'user_4',
      'user_5',
    ],
  };

  static final Map<String, List<String>> trackReposters =
      <String, List<String>>{
        'track_1': <String>['user_2', 'user_4'],
        'track_2': <String>['user_5'],
        'track_3': <String>['user_current_1', 'user_3', 'user_4'],
      };
}
