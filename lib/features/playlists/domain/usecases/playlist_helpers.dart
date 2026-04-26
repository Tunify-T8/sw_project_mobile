/// Pure domain functions for secret-token and embed-code logic.
/// No I/O, no Flutter dependencies — safe to unit test directly.
///
/// NOTE: The base URL is NOT hardcoded here. Pass [ApiEndpoints.baseUrl]
/// from the call site, keeping the URL in its single source of truth.
library;

// ─── Secret token ─────────────────────────────────────────────────────────────

/// Builds the shareable private-playlist URL from a [secretToken].
String buildSecretTokenShareUrl({
  required String secretToken,
  required String baseUrl,
}) {
  assert(secretToken.isNotEmpty, 'secretToken must not be empty');
  // Strip trailing /api suffix if present — the share URL is on the root domain.
  final root = baseUrl.replaceAll(RegExp(r'/api$'), '');
  return '$root/s/$secretToken';
}

/// Returns true when [token] has the expected format (32 hex characters).
bool isValidSecretToken(String token) {
  return RegExp(r'^[0-9a-f]{32}$').hasMatch(token);
}

// ─── Embed code ───────────────────────────────────────────────────────────────

/// Builds the iframe embed string for a public collection.
///
/// The backend already returns the full embed code via
/// GET /collections/:id/embed. Use this helper only for local preview
/// or when reconstructing the string without a network call.
String buildEmbedIframe({
  required String collectionId,
  required String baseUrl,
  int width = 100, // percentage
  int height = 166,
}) {
  assert(collectionId.isNotEmpty, 'collectionId must not be empty');
  final root = baseUrl.replaceAll(RegExp(r'/api$'), '');
  final src = '$root/embed/collections/$collectionId';
  return '<iframe src="$src" width="$width%" height="$height" '
      'frameborder="0"></iframe>';
}

// ─── Usage example ────────────────────────────────────────────────────────────
// import 'package:software_project/core/network/api_endpoints.dart';
//
// final shareUrl = buildSecretTokenShareUrl(
//   secretToken: playlist.secretToken!,
//   baseUrl: ApiEndpoints.baseUrl,
// );
//
// final iframe = buildEmbedIframe(
//   collectionId: playlist.id,
//   baseUrl: ApiEndpoints.baseUrl,
// );
