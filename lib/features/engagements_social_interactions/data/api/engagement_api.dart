
abstract class EngagementApi {
  Future<Map<String, dynamic>> getTrackEngagement({
    required String trackId,
  });

  Future<Map<String, dynamic>> toggleLike({
    required String trackId,
    required String viewerId,
  });

  Future<Map<String, dynamic>> toggleRepost({
    required String trackId,
    required String viewerId,
  });

  Future<List<Map<String, dynamic>>> getTrackComments({
    required String trackId,
  });

  Future<Map<String, dynamic>> addTimestampedComment({
    required String trackId,
    required String viewerId,
    required int timestamp,
    required String text,
  });

  Future<List<Map<String, dynamic>>> getTrackLikers({
    required String trackId,
  });

  Future<List<Map<String, dynamic>>> getTrackReposters({
    required String trackId,
  });
}
