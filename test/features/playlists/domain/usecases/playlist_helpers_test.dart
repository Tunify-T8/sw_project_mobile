import 'package:flutter_test/flutter_test.dart';
import 'package:software_project/features/playlists/domain/usecases/playlist_helpers.dart';

void main() {
  const kBaseUrl = 'https://api.example.com/api';
  const kRootUrl = 'https://api.example.com';

  group('buildSecretTokenShareUrl', () {
    test('strips /api suffix from baseUrl and appends token path', () {
      final url = buildSecretTokenShareUrl(
        secretToken: 'abc123',
        baseUrl: kBaseUrl,
      );

      expect(url, '$kRootUrl/s/abc123');
    });

    test('works when baseUrl has no /api suffix', () {
      final url = buildSecretTokenShareUrl(
        secretToken: 'def456',
        baseUrl: kRootUrl,
      );

      expect(url, '$kRootUrl/s/def456');
    });

    test('throws AssertionError for empty secretToken', () {
      expect(
        () => buildSecretTokenShareUrl(secretToken: '', baseUrl: kBaseUrl),
        throwsA(isA<AssertionError>()),
      );
    });

    test('includes full token in the path', () {
      const token = 'abcdef1234567890abcdef1234567890';
      final url = buildSecretTokenShareUrl(
        secretToken: token,
        baseUrl: kBaseUrl,
      );

      expect(url, contains('/s/$token'));
    });
  });

  group('isValidSecretToken', () {
    test('returns true for a valid 32 hex-character token', () {
      expect(
        isValidSecretToken('abcdef1234567890abcdef1234567890'),
        isTrue,
      );
    });

    test('returns false for token shorter than 32 characters', () {
      expect(isValidSecretToken('abc123'), isFalse);
    });

    test('returns false for token longer than 32 characters', () {
      expect(isValidSecretToken('abcdef1234567890abcdef12345678901'), isFalse);
    });

    test('returns false for token containing uppercase letters', () {
      expect(isValidSecretToken('ABCDEF1234567890abcdef1234567890'), isFalse);
    });

    test('returns false for empty string', () {
      expect(isValidSecretToken(''), isFalse);
    });

    test('returns false for token with non-hex characters', () {
      expect(isValidSecretToken('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'), isFalse);
    });

    test('returns true for all-digit token', () {
      expect(isValidSecretToken('12345678901234567890123456789012'), isTrue);
    });
  });

  group('buildEmbedIframe', () {
    test('strips /api suffix and builds correct iframe src', () {
      final iframe = buildEmbedIframe(
        collectionId: kPlaylistId,
        baseUrl: kBaseUrl,
      );

      expect(iframe, contains('$kRootUrl/embed/collections/$kPlaylistId'));
    });

    test('uses default width=100 and height=166', () {
      final iframe = buildEmbedIframe(
        collectionId: kPlaylistId,
        baseUrl: kBaseUrl,
      );

      expect(iframe, contains('width="100%"'));
      expect(iframe, contains('height="166"'));
    });

    test('uses custom width and height when provided', () {
      final iframe = buildEmbedIframe(
        collectionId: kPlaylistId,
        baseUrl: kBaseUrl,
        width: 80,
        height: 300,
      );

      expect(iframe, contains('width="80%"'));
      expect(iframe, contains('height="300"'));
    });

    test('includes frameborder="0"', () {
      final iframe = buildEmbedIframe(
        collectionId: kPlaylistId,
        baseUrl: kBaseUrl,
      );

      expect(iframe, contains('frameborder="0"'));
    });

    test('throws AssertionError for empty collectionId', () {
      expect(
        () => buildEmbedIframe(collectionId: '', baseUrl: kBaseUrl),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

const kPlaylistId = 'playlist-1';
