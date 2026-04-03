import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/cache/cache_directories.dart';
import '../../data/services/upload_waveform_service.dart';
import '../../domain/entities/upload_item.dart';
import 'track_detail_waveform_source.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final trackDetailWaveformProvider = Provider.autoDispose
    .family<TrackDetailWaveformState, UploadItem>((ref, item) {
      return TrackDetailWaveformState(
        waveformUrl: _resolveWaveformUrl(item),
        duration: Duration(seconds: item.durationSeconds),
      );
    });

/// Fetches/extracts waveform bars for a track.
/// Priority:
///   1. Already on the item (from DTO)
///   2. In-memory cache (same session, instant)
///   3. Disk cache  (survived app restart, no network needed)
///   4. Fetch JSON from backend waveformUrl (Supabase JSON file)
///   5. Extract locally from the audio file as last resort
/// After a successful network fetch or local extraction the bars are saved to
/// disk so future launches never need to repeat the work.
final Map<String, List<double>> _waveformBarsMemoryCache = <String, List<double>>{};

final trackDetailWaveformBarsProvider = FutureProvider.autoDispose
    .family<List<double>?, UploadItem>((ref, item) async {
      final cacheKey = item.id;

      // 1. Bars already embedded in the DTO.
      if (item.waveformBars != null && item.waveformBars!.isNotEmpty) {
        _waveformBarsMemoryCache[cacheKey] = item.waveformBars!;
        return item.waveformBars;
      }

      // 2. In-memory cache.
      final memoryCached = _waveformBarsMemoryCache[cacheKey];
      if (memoryCached != null && memoryCached.isNotEmpty) {
        return memoryCached;
      }

      // 3. Disk cache — survives app restarts.
      if (!kIsWeb) {
        final diskFile = await CacheDirectories.waveformFile(item.id);
        if (diskFile.existsSync()) {
          try {
            final raw = jsonDecode(diskFile.readAsStringSync());
            if (raw is List && raw.isNotEmpty) {
              final bars = raw.map((e) => (e as num).toDouble()).toList();
              _waveformBarsMemoryCache[cacheKey] = bars;
              return bars;
            }
          } catch (_) {
            // Corrupt disk file — delete and fall through to re-fetch.
            diskFile.deleteSync();
          }
        }
      }

      // 4. Fetch from backend waveformUrl.
      final waveformUrl = item.waveformUrl?.trim();
      if (waveformUrl != null && waveformUrl.isNotEmpty) {
        final bars = await _fetchWaveformJson(waveformUrl);
        if (bars != null && bars.isNotEmpty) {
          _waveformBarsMemoryCache[cacheKey] = bars;
          _saveToDisk(item.id, bars);
          return bars;
        }
      }

      // 5. Local extraction from audio file.
      final extracted = await _extractWaveformBars(item);
      if (extracted != null && extracted.isNotEmpty) {
        _waveformBarsMemoryCache[cacheKey] = extracted;
        _saveToDisk(item.id, extracted);
      }
      return extracted;
    });

// ── State ─────────────────────────────────────────────────────────────────────

class TrackDetailWaveformState {
  const TrackDetailWaveformState({
    required this.waveformUrl,
    required this.duration,
  });

  final String? waveformUrl;
  final Duration duration;

  bool get hasWaveform => waveformUrl != null;
}

String formatTrackDetailDuration(Duration value) {
  final minutes = value.inMinutes;
  final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

final UploadWaveformService _waveformService = UploadWaveformService();

// ── URL resolution ────────────────────────────────────────────────────────────

/// Returns the waveformUrl directly because the backend stores peaks as a JSON
/// file in storage.
String? _resolveWaveformUrl(UploadItem item) {
  final url = item.waveformUrl?.trim();
  if (url != null && url.isNotEmpty) return url;
  return null;
}

// ── Waveform JSON fetch ───────────────────────────────────────────────────────

/// The backend processor uploads waveform peaks as a JSON file to Supabase.
/// Format is either a plain array [0.1, 0.5, ...] or { peaks: [...] }.
Future<List<double>?> _fetchWaveformJson(String url) async {
  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);

    List<dynamic>? rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map) {
      // Some waveform services use { peaks: [...] } or { data: [...] }
      rawList = (decoded['peaks'] ?? decoded['data'] ?? decoded['waveform'])
          as List<dynamic>?;
    }

    if (rawList == null || rawList.isEmpty) return null;

    final bars = rawList
        .map((e) => (e as num).toDouble())
        .toList();

    // Normalize to 0–1 if values look like they're in a different range
    final max = bars.reduce((a, b) => a > b ? a : b);
    if (max > 1.0) {
      return bars.map((v) => (v / max).clamp(0.0, 1.0)).toList();
    }

    return buildDisplayWaveformBars(bars, targetBarCount: 180);
  } catch (_) {
    return null;
  }
}

// ── Disk persistence ──────────────────────────────────────────────────────────

/// Saves [bars] to the persistent waveform cache file for [trackId].
/// Fire-and-forget — errors are swallowed so they never affect the UI.
void _saveToDisk(String trackId, List<double> bars) {
  if (kIsWeb) return;
  CacheDirectories.waveformFile(trackId).then((file) {
    file.writeAsString(jsonEncode(bars));
  }).catchError((_) {});
}

// ── Local extraction ──────────────────────────────────────────────────────────

Future<List<double>?> _extractWaveformBars(UploadItem item) async {
  if (kIsWeb) return null;
  if (!Platform.isAndroid && !Platform.isIOS) return null;

  final sourcePath = await resolveTrackDetailWaveformSource(item);
  if (sourcePath == null) return null;

  return _waveformService.generateDisplayBarsFromFile(
    sourcePath,
    targetBarCount: 180,
  );
}
