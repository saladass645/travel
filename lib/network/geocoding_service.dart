import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// One geocoding hit returned by [GeocodingService.search].
class DestinationHit {
  DestinationHit({
    required this.label,
    required this.subtitle,
    required this.lat,
    required this.lon,
    this.kind,
  });

  /// Short display name (e.g. "Kyoto", "Paris").
  final String label;

  /// One-line context (e.g. "Kansai, Japan").
  final String subtitle;

  final double lat;
  final double lon;

  /// OSM "type" / class, useful for picking an icon.
  final String? kind;

  /// What we save back into the trip's `destination` column.
  String get displayValue {
    if (subtitle.isEmpty) return label;
    return '$label, ${_country(subtitle)}';
  }

  static String _country(String s) {
    final parts = s.split(',').map((p) => p.trim()).toList();
    return parts.isEmpty ? s : parts.last;
  }
}

/// Free, no-key destination search via Nominatim / OpenStreetMap.
///
/// Nominatim's usage policy requires:
///   * a meaningful User-Agent
///   * at most 1 request per second
/// We debounce in the picker UI (300ms) and serialise outgoing calls here.
class GeocodingService {
  GeocodingService._();
  static final instance = GeocodingService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://nominatim.openstreetmap.org',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      // Nominatim asks every caller to identify themselves. Generic UA is OK
      // for low-volume use; bump this if the app sees real traffic.
      'User-Agent': 'voyage-travel-app/1.0',
      'Accept': 'application/json',
    },
  ));

  Future<void>? _inflight;
  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  Future<List<DestinationHit>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    while (_inflight != null) {
      await _inflight;
    }
    final completer = Completer<void>();
    _inflight = completer.future;

    try {
      final gap = DateTime.now().difference(_lastSent);
      if (gap < const Duration(milliseconds: 1100)) {
        await Future.delayed(const Duration(milliseconds: 1100) - gap);
      }
      _lastSent = DateTime.now();

      final response = await _dio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': q,
          'format': 'json',
          'addressdetails': 1,
          'limit': 8,
          'featuretype': 'city',
          'accept-language': 'en',
        },
      );
      final data = response.data ?? const [];
      return data.map(_toHit).whereType<DestinationHit>().toList();
    } catch (e) {
      debugPrint('[Geocoding] search failed: $e');
      return const [];
    } finally {
      completer.complete();
      _inflight = null;
    }
  }

  DestinationHit? _toHit(dynamic raw) {
    if (raw is! Map) return null;
    final map = raw.cast<String, dynamic>();
    final lat = double.tryParse(map['lat']?.toString() ?? '');
    final lon = double.tryParse(map['lon']?.toString() ?? '');
    if (lat == null || lon == null) return null;

    final address = (map['address'] as Map?)?.cast<String, dynamic>();
    final label = (address?['city'] as String?) ??
        (address?['town'] as String?) ??
        (address?['village'] as String?) ??
        (address?['state'] as String?) ??
        (address?['country'] as String?) ??
        _firstChunk(map['display_name'] as String?) ??
        'Unknown';

    final region = address?['state'] as String?;
    final country = address?['country'] as String?;
    final subtitle = [
      if (region != null && region.isNotEmpty && region != label) region,
      if (country != null && country.isNotEmpty) country,
    ].join(', ');

    return DestinationHit(
      label: label,
      subtitle: subtitle,
      lat: lat,
      lon: lon,
      kind: map['type'] as String?,
    );
  }

  String? _firstChunk(String? display) {
    if (display == null) return null;
    final comma = display.indexOf(',');
    return comma < 0 ? display : display.substring(0, comma);
  }
}
