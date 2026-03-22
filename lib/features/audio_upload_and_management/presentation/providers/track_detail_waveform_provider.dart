import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
///   1. Already on the item (from DTO — unlikely for getMyTracks)
///   2. Fetch the JSON from the backend waveformUrl (Supabase JSON file)
///   3. Extract locally from the audio file as last resort
final trackDetailWaveformBarsProvider = FutureProvider.autoDispose
    .family<List<double>?, UploadItem>((ref, item) async {
      // 1. Already have bars
      if (item.waveformBars != null && item.waveformBars!.isNotEmpty) {
        return item.waveformBars;
      }

      // 2. Fetch from backend waveform JSON URL (Supabase storage)
      final waveformUrl = item.waveformUrl?.trim();
      if (waveformUrl != null && waveformUrl.isNotEmpty) {
        final bars = await _fetchWaveformJson(waveformUrl);
        if (bars != null && bars.isNotEmpty) return bars;
      }

      // 3. Fall back to local extraction
      return _extractWaveformBars(item);
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

/// Returns the waveformUrl directly — backend stores peaks as a JSON file
/// on Supabase. No Cloudinary derivation needed.
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