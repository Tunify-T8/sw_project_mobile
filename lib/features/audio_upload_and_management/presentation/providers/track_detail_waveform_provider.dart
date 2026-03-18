import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waveform_extractor/waveform_extractor.dart';

import '../../domain/entities/upload_item.dart';
import '../../shared/upload_error_helpers.dart';
import 'track_detail_waveform_source.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final trackDetailWaveformProvider = Provider.autoDispose
    .family<TrackDetailWaveformState, UploadItem>((ref, item) {
      return TrackDetailWaveformState(
        waveformUrl: resolveTrackDetailWaveformUrl(item),
        duration: Duration(seconds: item.durationSeconds),
      );
    });

/// Extracts real waveform bars from the audio file.
/// Returns null only when no audio source is available at all.
final trackDetailWaveformBarsProvider = FutureProvider.autoDispose
    .family<List<double>?, UploadItem>((ref, item) async {
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

// ── Cache ─────────────────────────────────────────────────────────────────────
// Keyed by localFilePath (the actual audio content), NOT track id.
// This guarantees two different uploaded files always get different waveforms.

final Map<String, List<double>> _waveformBarsCache = {};

String _cacheKey(UploadItem item) =>
    item.localFilePath?.trim().isNotEmpty == true
    ? item.localFilePath!
    : item.id;

// ── URL resolution ────────────────────────────────────────────────────────────

String? resolveTrackDetailWaveformUrl(UploadItem item) {
  final derived = _deriveCloudinaryWaveformUrl(item.audioUrl);
  if (derived != null) return derived;
  final raw = item.waveformUrl?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  return null;
}

String? _deriveCloudinaryWaveformUrl(String? audioUrl) {
  final url = audioUrl?.trim();
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.host.contains('res.cloudinary.com')) return null;
  const marker = '/video/upload/';
  final idx = url.indexOf(marker);
  if (idx < 0) return null;
  final prefix = url.substring(0, idx + marker.length);
  final asset = url.substring(idx + marker.length);
  final dot = asset.lastIndexOf('.');
  if (dot <= 0) return null;
  final pub = asset.substring(0, dot);
  return '${prefix}fl_waveform,w_1600,h_320,c_fit,co_rgb:ffffff/$pub.png';
}

// ── Extraction ────────────────────────────────────────────────────────────────

Future<List<double>?> _extractWaveformBars(UploadItem item) async {
  final key = _cacheKey(item);
  final cached = _waveformBarsCache[key];
  if (cached != null && cached.isNotEmpty) return cached;

  if (kIsWeb) return null;
  if (!Platform.isAndroid && !Platform.isIOS) return null;

  final sourcePath = await resolveTrackDetailWaveformSource(item);
  if (sourcePath == null) return null;

  try {
    final extractor = WaveformExtractor();
    final result = await extractor
        .extractWaveform(sourcePath)
        .timeout(const Duration(seconds: 30));

    final raw = result.waveformData;
    if (raw.isEmpty) return null;

    final bars = _buildDisplayBars(
      raw.map((v) => v.toDouble()).toList(),
      targetBarCount: 170,
    );
    if (bars.isNotEmpty) {
      _waveformBarsCache[key] = bars;
      return bars;
    }
    return null;
  } catch (error, stackTrace) {
    logUploadError('extract waveform bars', error, stackTrace);
    throw const UploadFlowException(
      'We could not generate the waveform for this track right now.',
    );
  }
}

// ── Bar normalisation ─────────────────────────────────────────────────────────

List<double> _buildDisplayBars(
  List<double> rawSamples, {
  required int targetBarCount,
}) {
  final cleaned = rawSamples
      .where((v) => v.isFinite)
      .map((v) => v.abs())
      .where((v) => v > 0)
      .toList(growable: false);

  if (cleaned.isEmpty) return const [];

  final count = math.min(targetBarCount, math.max(48, cleaned.length));
  final grouped = <double>[];

  for (var i = 0; i < count; i++) {
    final start = (i * cleaned.length / count).floor();
    final end = math.max(start + 1, ((i + 1) * cleaned.length / count).ceil());

    var peak = 0.0;
    var sumSq = 0.0;
    var n = 0;

    for (var s = start; s < end && s < cleaned.length; s++) {
      final v = cleaned[s];
      if (v > peak) peak = v;
      sumSq += v * v;
      n++;
    }

    final rms = n == 0 ? 0.0 : math.sqrt(sumSq / n);
    grouped.add((peak * 0.72) + (rms * 0.28));
  }

  final sorted = [...grouped]..sort();
  final p95idx = ((sorted.length - 1) * 0.95).round().clamp(
    0,
    sorted.length - 1,
  );
  final refPeak = math.max(sorted[p95idx], 0.000001);

  return grouped
      .map((b) {
        final norm = (b / refPeak).clamp(0.0, 1.0).toDouble();
        final boosted = math.pow(norm, 0.58).toDouble();
        return (0.08 + (boosted * 0.92)).clamp(0.08, 1.0).toDouble();
      })
      .toList(growable: false);
}
