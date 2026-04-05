import '../../domain/entities/trending_genre_entity.dart';
import '../../domain/entities/trending_track_entity.dart';

class MockTrendingService {
  Future<TrendingGenreEntity> getTrendingByGenre({
    required String genre,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    switch (genre.toLowerCase()) {
      case 'pop':
        return TrendingGenreEntity(
          genre: 'Pop',
          tracks: [
            TrendingTrackEntity(
              trackId: 'pop_track_1',
              title: 'Midnight Echo',
              artistName: 'Luna Waves',
              coverUrl: 'https://picsum.photos/300/300?random=1',
              isLiked: false,
              isReposted: false,
            ),
            TrendingTrackEntity(
              trackId: 'pop_track_2',
              title: 'Neon Dreams',
              artistName: 'Skyline',
              coverUrl: 'https://picsum.photos/300/300?random=2',
              isLiked: true,
              isReposted: false,
            ),
            TrendingTrackEntity(
              trackId: 'pop_track_3',
              title: 'Summer Motion',
              artistName: 'Livi',
              coverUrl: 'https://picsum.photos/300/300?random=12',
              isLiked: true,
              isReposted: true,
            ),
            TrendingTrackEntity(
              trackId: 'pop_track_4',
              title: 'Sugar Lights',
              artistName: 'Romy K',
              coverUrl: 'https://picsum.photos/300/300?random=16',
              isLiked: false,
              isReposted: false,
            ),
            TrendingTrackEntity(
              trackId: 'pop_track_5',
              title: 'City Glow',
              artistName: 'Nova Sky',
              coverUrl: 'https://picsum.photos/300/300?random=17',
              isLiked: true,
              isReposted: false,
            ),
          ],
        );

      case 'jazz':
        return TrendingGenreEntity(
          genre: 'Jazz',
          tracks: [
            TrendingTrackEntity(
              trackId: 'jazz_track_1',
              title: 'Blue Smoke',
              artistName: 'Jazz Flow',
              coverUrl: 'https://picsum.photos/300/300?random=3',
              isLiked: false,
              isReposted: true,
            ),
            TrendingTrackEntity(
              trackId: 'jazz_track_2',
              title: 'Late Night Sax',
              artistName: 'Soul Avenue',
              coverUrl: 'https://picsum.photos/300/300?random=4',
              isLiked: false,
              isReposted: false,
            ),
            TrendingTrackEntity(
              trackId: 'jazz_track_3',
              title: 'Velvet Sky',
              artistName: 'Miles June',
              coverUrl: 'https://picsum.photos/300/300?random=13',
              isLiked: true,
              isReposted: false,
            ),
          ],
        );

      case 'electronic':
        return TrendingGenreEntity(
          genre: 'Electronic',
          tracks: [
            TrendingTrackEntity(
              trackId: 'electronic_track_1',
              title: 'Bassline Rush',
              artistName: 'Drop Unit',
              coverUrl: 'https://picsum.photos/300/300?random=5',
              isLiked: true,
              isReposted: true,
            ),
            TrendingTrackEntity(
              trackId: 'electronic_track_2',
              title: 'Static Pulse',
              artistName: 'Volt',
              coverUrl: 'https://picsum.photos/300/300?random=6',
              isLiked: false,
              isReposted: false,
            ),
            TrendingTrackEntity(
              trackId: 'electronic_track_3',
              title: 'Orbit Fade',
              artistName: 'Nulla',
              coverUrl: 'https://picsum.photos/300/300?random=14',
              isLiked: false,
              isReposted: true,
            ),
          ],
        );

      case 'rock, metal, punk':
        return TrendingGenreEntity(
          genre: 'Rock, Metal, Punk',
          tracks: [
            TrendingTrackEntity(
              trackId: 'rock_track_1',
              title: 'Static Dreams',
              artistName: 'Nova',
              coverUrl: 'https://picsum.photos/300/300?random=7',
              isLiked: false,
              isReposted: false,
            ),
            TrendingTrackEntity(
              trackId: 'rock_track_2',
              title: 'Riot Avenue',
              artistName: 'Crashline',
              coverUrl: 'https://picsum.photos/300/300?random=8',
              isLiked: true,
              isReposted: true,
            ),
          ],
        );

      case 'soul':
        return TrendingGenreEntity(
          genre: 'Soul',
          tracks: [
            TrendingTrackEntity(
              trackId: 'soul_track_1',
              title: 'Golden Hour',
              artistName: 'Mira',
              coverUrl: 'https://picsum.photos/300/300?random=9',
              isLiked: true,
              isReposted: true,
            ),
            TrendingTrackEntity(
              trackId: 'soul_track_2',
              title: 'Honey Notes',
              artistName: 'Sena',
              coverUrl: 'https://picsum.photos/300/300?random=10',
              isLiked: false,
              isReposted: false,
            ),
          ],
        );

      case 'hip hop & rap':
        return TrendingGenreEntity(
          genre: 'Hip Hop & Rap',
          tracks: [
            TrendingTrackEntity(
              trackId: 'hiphop_track_1',
              title: 'Backseat Bars',
              artistName: 'Mako',
              coverUrl: 'https://picsum.photos/300/300?random=11',
              isLiked: true,
              isReposted: true,
            ),
            TrendingTrackEntity(
              trackId: 'hiphop_track_2',
              title: 'No Sleep City',
              artistName: 'Ty Ren',
              coverUrl: 'https://picsum.photos/300/300?random=15',
              isLiked: true,
              isReposted: false,
            ),
          ],
        );

      default:
        return TrendingGenreEntity(
          genre: genre,
          tracks: [],
        );
    }
  }
}