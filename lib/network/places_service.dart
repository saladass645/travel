import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_app/data/continents.dart';
import 'package:travel_app/network/foursquare_service.dart';

const String _kApiKey = String.fromEnvironment('OPENTRIPMAP_API_KEY');

class PlacesService {
  PlacesService._();
  static final instance = PlacesService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.opentripmap.com/0.1/en',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // Spacing between requests + retry policy for 429.
  static const Duration _minGap = Duration(milliseconds: 550);
  static const int _maxRetries = 4;
  static const List<int> _retryBackoffMs = [1500, 3500, 7000, 12000];

  Future<void>? _inflight;
  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  bool get hasApiKey => _kApiKey.isNotEmpty;

  List<Map<String, dynamic>>? _allTourCache;
  final Map<String, Map<String, dynamic>> _detailCache = {};

  /// Returns all tour rows across every featured continent. Cached after the
  /// first call so repeat fetches (continent tab switches, search) are instant.
  Future<List<Map<String, dynamic>>> fetchAllTours() async {
    final cached = _allTourCache;
    if (cached != null) return cached;

    if (!hasApiKey) {
      debugPrint(
          '[PlacesService] OPENTRIPMAP_API_KEY not set; returning no tours.');
      _allTourCache = const [];
      return const [];
    }

    final merged = <Map<String, dynamic>>[];
    for (final continent in kContinents) {
      merged.addAll(await fetchTours(continent));
    }
    _allTourCache = merged;
    return merged;
  }

  Future<List<Map<String, dynamic>>> fetchTours(
      ContinentInfo continent) async {
    if (!hasApiKey) return const [];

    final rows = <Map<String, dynamic>>[];
    for (final city in continent.featuredCities) {
      rows.addAll(await _toursNearCity(city, continent));
    }
    return rows;
  }

  Future<List<Map<String, dynamic>>> _toursNearCity(
      FeaturedCity city, ContinentInfo continent) async {
    try {
      final response = await _throttledGet(
        '/places/radius',
        queryParameters: {
          'radius': 12000,
          'lon': city.lon,
          'lat': city.lat,
          'kinds':
              'interesting_places,architecture,cultural,historic,museums',
          'rate': '2h',
          'limit': 3,
          'format': 'json',
          'apikey': _kApiKey,
        },
      );
      final list = (response.data as List).cast<Map<String, dynamic>>();
      final tours = <Map<String, dynamic>>[];
      for (final item in list) {
        final xid = item['xid'] as String?;
        if (xid == null || xid.isEmpty) continue;
        try {
          final detail = await _placeDetail(xid);
          tours.add(_toTourRow(detail, city, continent));
        } catch (e) {
          debugPrint('[PlacesService] detail failed for $xid: $e');
        }
      }

      // Pre-fetch image bytes (parallel — different host than OpenTripMap,
      // not bound by our request throttle). Swap to picsum on hard failure.
      await Future.wait(tours.map((tour) => _ensureImageReady(tour, city)));

      return tours;
    } catch (e) {
      debugPrint('[PlacesService] failed for ${city.name}: $e');
      return const [];
    }
  }

  Future<Map<String, dynamic>> _placeDetail(String xid) async {
    final cached = _detailCache[xid];
    if (cached != null) return cached;

    final response = await _throttledGet(
      '/places/xid/$xid',
      queryParameters: {'apikey': _kApiKey},
    );
    final data = (response.data as Map).cast<String, dynamic>();
    _detailCache[xid] = data;
    return data;
  }

  /// Serializes outgoing requests with a minimum gap and retries on 429.
  Future<Response<dynamic>> _throttledGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // Wait for any in-flight request so callers form a single queue.
    while (_inflight != null) {
      await _inflight;
    }
    final completer = Completer<void>();
    _inflight = completer.future;

    try {
      for (var attempt = 0; attempt <= _maxRetries; attempt++) {
        final gap = DateTime.now().difference(_lastSent);
        if (gap < _minGap) {
          await Future.delayed(_minGap - gap);
        }

        try {
          _lastSent = DateTime.now();
          return await _dio.get(path, queryParameters: queryParameters);
        } on DioException catch (e) {
          final status = e.response?.statusCode ?? 0;
          if (status == 429 && attempt < _maxRetries) {
            final ms =
                _retryBackoffMs[attempt.clamp(0, _retryBackoffMs.length - 1)];
            debugPrint('[PlacesService] 429 on $path, backing off ${ms}ms');
            await Future.delayed(Duration(milliseconds: ms));
            continue;
          }
          rethrow;
        }
      }
      throw StateError('Unreachable: retry loop should return or throw.');
    } finally {
      completer.complete();
      _inflight = null;
    }
  }

  Map<String, dynamic> _toTourRow(
    Map<String, dynamic> detail,
    FeaturedCity city,
    ContinentInfo continent,
  ) {
    final wikiExtracts = detail['wikipedia_extracts'] as Map?;
    final info = detail['info'] as Map?;
    final point = detail['point'] as Map?;

    final xid = (detail['xid'] as String?) ?? city.name;

    // Try OpenTripMap's bundled Wikipedia photo first. Detail responses include
    // `preview: { source, height, width }` and sometimes a top-level `image`,
    // both CDN-hosted Wikimedia URLs. If neither is present we fall back to a
    // picsum placeholder; _ensureImageReady upgrades that to a real photo via
    // Wikipedia's REST API or Foursquare when available.
    final previewSource =
        _httpsify((detail['preview'] as Map?)?['source'] as String?);
    final detailImage = _httpsify(detail['image'] as String?);
    final fallback =
        'https://picsum.photos/seed/${Uri.encodeQueryComponent(xid)}/600/400';
    final image = (previewSource != null && previewSource.isNotEmpty)
        ? previewSource
        : (detailImage != null && detailImage.isNotEmpty
            ? detailImage
            : fallback);

    final overview = (wikiExtracts?['text'] as String?) ??
        (info?['descr'] as String?) ??
        '${detail['name'] ?? city.name} — a notable site near ${city.name}.';

    final kinds = (detail['kinds'] as String?) ?? '';
    final firstKind = kinds.split(',').isNotEmpty
        ? _humanize(kinds.split(',').first)
        : 'Cultural';

    return <String, dynamic>{
      'id': detail['xid'] ?? '',
      'title': (detail['name'] as String?)?.isNotEmpty == true
          ? detail['name']
          : city.name,
      'continent': continent.displayNames['en'],
      'image': image,
      'images': <String>[image],
      'overview': overview,
      'distance': 0,
      'weather_condition': 'Sunny',
      'rating': 4.5,
      'number_of_reviews': 100,
      'started_price': 200,
      'temperature': 25,
      'duration_day': 3,
      'category': firstKind,
      'extra_price': 50,
      'details': overview,
      'reviews': '',
      'costs': 'Approximate starting price: \$200 per night.',
      '_lat': (point?['lat'] as num?)?.toDouble(),
      '_lon': (point?['lon'] as num?)?.toDouble(),
      '_city': city.name,
      '_wiki': detail['wikipedia'] as String?,
      '_hasRealImage':
          (previewSource?.isNotEmpty == true) || (detailImage?.isNotEmpty == true),
    };
  }

  String? _httpsify(String? url) {
    if (url == null || url.isEmpty) return url;
    if (url.startsWith('http://')) return 'https://' + url.substring(7);
    return url;
  }

  String _humanize(String s) {
    if (s.isEmpty) return s;
    final cleaned = s.replaceAll('_', ' ');
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  /// Upgrades the tour's placeholder image to a real photo when possible.
  ///
  /// Order:
  ///   1. If OpenTripMap already supplied a real image, do nothing.
  ///   2. Try Wikipedia's REST API thumbnail (no key, public, reliable).
  ///   3. Try Foursquare venue lookup (when a key is configured).
  ///
  /// On every failure path the picsum placeholder stays in place so the card
  /// always shows something.
  Future<void> _ensureImageReady(
      Map<String, dynamic> tour, FeaturedCity city) async {
    if (tour['_hasRealImage'] == true) return;

    final wiki = await _wikipediaThumbnail(tour);
    if (wiki != null && wiki.isNotEmpty) {
      tour['image'] = wiki;
      tour['images'] = <String>[wiki];
      tour['_hasRealImage'] = true;
      return;
    }

    if (!FoursquareService.instance.hasKey) return;
    final lat = tour['_lat'] as double?;
    final lon = tour['_lon'] as double?;
    if (lat == null || lon == null) return;
    final title = (tour['title'] as String?) ?? city.name;
    final url = await FoursquareService.instance.findPhoto(
      name: title,
      lat: lat,
      lon: lon,
    );
    if (url == null || url.isEmpty) return;
    tour['image'] = url;
    tour['images'] = <String>[url];
    tour['_hasRealImage'] = true;
  }

  /// Fetches the Wikipedia REST summary's thumbnail for the tour. Uses the
  /// `wikipedia` URL when OpenTripMap returned one (most reliable, since it
  /// maps to an article that's actually about *this* place); otherwise falls
  /// back to a title-based summary lookup keyed on the place name.
  Future<String?> _wikipediaThumbnail(Map<String, dynamic> tour) async {
    String? title;
    final wikiUrl = tour['_wiki'] as String?;
    if (wikiUrl != null && wikiUrl.isNotEmpty) {
      final match = RegExp(r'/wiki/([^?#]+)').firstMatch(wikiUrl);
      if (match != null) {
        title = Uri.decodeComponent(match.group(1)!);
      }
    }
    title ??= tour['title'] as String?;
    if (title == null || title.isEmpty) return null;

    try {
      final response = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      )).get(
        'https://en.wikipedia.org/api/rest_v1/page/summary/'
        '${Uri.encodeComponent(title)}',
        options: Options(
          headers: const {'accept': 'application/json'},
          // Wikipedia returns a 404 page for missing titles. Don't throw.
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (response.statusCode != 200) return null;
      final data = (response.data as Map).cast<String, dynamic>();
      final thumb = (data['thumbnail'] as Map?)?['source'] as String?;
      final original =
          (data['originalimage'] as Map?)?['source'] as String?;
      return _httpsify(original ?? thumb);
    } catch (e) {
      debugPrint('[Wikipedia] thumbnail failed for "$title": $e');
      return null;
    }
  }
}
