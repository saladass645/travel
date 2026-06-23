import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const String _kApiKey = String.fromEnvironment('FOURSQUARE_API_KEY');

class FoursquareService {
  FoursquareService._();
  static final instance = FoursquareService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.foursquare.com/v3',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // Cache: "name|lat,lon" -> photo URL (or null if no match). Keeps repeat
  // lookups for the same POI free and well under the 100K/mo free tier.
  final Map<String, String?> _photoCache = {};

  bool get hasKey => _kApiKey.isNotEmpty;

  /// Looks up the venue at [lat]/[lon] matching [name] on Foursquare and
  /// returns the URL of its first photo. Returns null on any failure
  /// (no key, no match, no photo, network error) so callers can fall back.
  Future<String?> findPhoto({
    required String name,
    required double lat,
    required double lon,
  }) async {
    if (!hasKey) return null;

    final cacheKey = '$name|$lat,$lon';
    if (_photoCache.containsKey(cacheKey)) return _photoCache[cacheKey];

    try {
      final fsqId = await _searchVenue(name: name, lat: lat, lon: lon);
      if (fsqId == null) {
        _photoCache[cacheKey] = null;
        return null;
      }
      final url = await _firstPhoto(fsqId);
      _photoCache[cacheKey] = url;
      return url;
    } catch (e) {
      debugPrint('[Foursquare] failed for "$name": $e');
      _photoCache[cacheKey] = null;
      return null;
    }
  }

  Future<String?> _searchVenue({
    required String name,
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get(
      '/places/search',
      queryParameters: {
        'll': '$lat,$lon',
        'radius': 500,
        'query': name,
        'limit': 1,
      },
      options: Options(headers: {
        'Authorization': _kApiKey,
        'Accept': 'application/json',
      }),
    );
    final results = (response.data['results'] as List?) ?? const [];
    if (results.isEmpty) return null;
    return (results.first as Map)['fsq_id'] as String?;
  }

  Future<String?> _firstPhoto(String fsqId) async {
    final response = await _dio.get(
      '/places/$fsqId/photos',
      queryParameters: {'limit': 1},
      options: Options(headers: {
        'Authorization': _kApiKey,
        'Accept': 'application/json',
      }),
    );
    final photos = response.data as List?;
    if (photos == null || photos.isEmpty) return null;
    final first = (photos.first as Map).cast<String, dynamic>();
    final prefix = first['prefix'] as String?;
    final suffix = first['suffix'] as String?;
    if (prefix == null || suffix == null) return null;
    // Foursquare returns prefix/suffix and expects callers to insert a size.
    // 'original' = source resolution.
    return '$prefix' 'original' '$suffix';
  }
}
