// Upload Feature Guide:
// Purpose: Generates and normalizes waveform bar data from local audio files for preview and detail views.
// Used by: cloudinary_upload_repository_impl, cloudinary_upload_workflow, mock_upload_service, and 1 more upload files.
// Concerns: Multi-format support; Waveform generation.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:waveform_extractor/waveform_extractor.dart';

import '../../shared/upload_error_helpers.dart';

class UploadWaveformService {
  final Map<String, List<double>> _cache = {};

  Future<List<double>?> generateDisplayBarsFromFile(
    String filePath, {
    int targetBarCount = 180,
  }) async {
    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) {
      return null;
    }

    final cached = _cache[normalizedPath];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    if (!_supportsWaveformGeneration()) {
      return null;
    }

    final sourceFile = File(normalizedPath);
    if (!sourceFile.existsSync()) {
      return null;
    }

    try {
      final result = await WaveformExtractor()
          .extractWaveform(normalizedPath)
          .timeout(const Duration(seconds: 45));
      final bars = buildDisplayWaveformBars(
        result.waveformData.map((value) => value.toDouble()).toList(),
        targetBarCount: targetBarCount,
      );

      if (bars.isEmpty) {
        return null;
      }

      _cache[normalizedPath] = bars;
      return bars;
    } catch (error, stackTrace) {
      logUploadError('generate waveform bars', error, stackTrace);
      return null;
    }
  }
}

bool _supportsWaveformGeneration() {
  if (kIsWeb) {
    return false;
  }
  return Platform.isAndroid || Platform.isIOS;
}

List<double> buildDisplayWaveformBars(
  List<double> rawSamples, {
  required int targetBarCount,
}) {
  final cleaned = rawSamples
      .where((value) => value.isFinite)
      .map((value) => value.abs())
      .toList(growable: false);

  if (cleaned.isEmpty || cleaned.every((value) => value <= 0)) {
    return const [];
  }

  final bucketCount = math.min(targetBarCount, cleaned.length);
  final groupedPeaks = <double>[];

  for (var index = 0; index < bucketCount; index++) {
    final start = (index * cleaned.length / bucketCount).floor();
    final end = math.max(
      start + 1,
      ((index + 1) * cleaned.length / bucketCount).ceil(),
    );

    var peak = 0.0;
    for (
      var sampleIndex = start;
      sampleIndex < end && sampleIndex < cleaned.length;
      sampleIndex++
    ) {
      final sample = cleaned[sampleIndex];
      if (sample > peak) {
        peak = sample;
      }
    }

    groupedPeaks.add(peak);
  }

  final sortedPeaks = [...groupedPeaks]..sort();
  final referenceIndex = ((sortedPeaks.length - 1) * 0.985).round().clamp(
    0,
    sortedPeaks.length - 1,
  );
  final referencePeak = math.max(sortedPeaks[referenceIndex], 0.000001);

  return groupedPeaks
      .map((peak) {
        final normalized = (peak / referencePeak).clamp(0.0, 1.0).toDouble();
        final softened = math.pow(normalized, 0.82).toDouble();
        return (0.02 + (softened * 0.98)).clamp(0.02, 1.0).toDouble();
      })
      .toList(growable: false);
}
