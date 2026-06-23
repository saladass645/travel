import 'package:dio/dio.dart';

class CountryInfo {
  final String name;
  final String? officialName;
  final String? capital;
  final double? capitalLat;
  final double? capitalLon;
  final String? flagUrl;
  final String? region;

  CountryInfo({
    required this.name,
    this.officialName,
    this.capital,
    this.capitalLat,
    this.capitalLon,
    this.flagUrl,
    this.region,
  });
}

class CountriesService {
  CountriesService._();
  static final instance = CountriesService._();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://restcountries.com/v3.1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 20),
  ));

  final Map<String, List<CountryInfo>> _regionCache = {};

  Future<List<CountryInfo>> byRegion(String region) async {
    final cached = _regionCache[region];
    if (cached != null) return cached;

    final response = await _dio.get(
      '/region/$region',
      queryParameters: {
        'fields': 'name,capital,capitalInfo,flags,region',
      },
    );

    final data = response.data as List;
    final countries = data
        .map((c) => _parse(c as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    _regionCache[region] = countries;
    return countries;
  }

  CountryInfo _parse(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>?;
    final capitalList = json['capital'] as List?;
    final capitalInfo = json['capitalInfo'] as Map<String, dynamic>?;
    final latlng = capitalInfo?['latlng'] as List?;
    final flags = json['flags'] as Map<String, dynamic>?;

    double? lat;
    double? lon;
    if (latlng != null && latlng.length == 2) {
      lat = (latlng[0] as num?)?.toDouble();
      lon = (latlng[1] as num?)?.toDouble();
    }

    return CountryInfo(
      name: (name?['common'] as String?) ?? '',
      officialName: name?['official'] as String?,
      capital: (capitalList != null && capitalList.isNotEmpty)
          ? capitalList.first as String?
          : null,
      capitalLat: lat,
      capitalLon: lon,
      flagUrl: flags?['png'] as String?,
      region: json['region'] as String?,
    );
  }
}
