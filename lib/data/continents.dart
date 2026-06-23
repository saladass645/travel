class FeaturedCity {
  final String name;
  final double lat;
  final double lon;
  const FeaturedCity({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

class ContinentInfo {
  final String key;
  final Map<String, String> displayNames;
  final String restCountriesRegion;
  final List<FeaturedCity> featuredCities;

  const ContinentInfo({
    required this.key,
    required this.displayNames,
    required this.restCountriesRegion,
    required this.featuredCities,
  });

  String displayName(String lang) =>
      displayNames[lang] ?? displayNames['en'] ?? key;
}

const List<ContinentInfo> kContinents = [
  ContinentInfo(
    key: 'asia',
    displayNames: {'en': 'Asia', 'ar': 'آسيا'},
    restCountriesRegion: 'asia',
    featuredCities: [
      FeaturedCity(name: 'Tokyo', lat: 35.6895, lon: 139.6917),
      FeaturedCity(name: 'Bangkok', lat: 13.7563, lon: 100.5018),
    ],
  ),
  ContinentInfo(
    key: 'europe',
    displayNames: {'en': 'Europe', 'ar': 'أوروبا'},
    restCountriesRegion: 'europe',
    featuredCities: [
      FeaturedCity(name: 'Paris', lat: 48.8566, lon: 2.3522),
      FeaturedCity(name: 'Rome', lat: 41.9028, lon: 12.4964),
    ],
  ),
  ContinentInfo(
    key: 'americas',
    displayNames: {'en': 'Americas', 'ar': 'الأمريكتان'},
    restCountriesRegion: 'americas',
    featuredCities: [
      FeaturedCity(name: 'New York', lat: 40.7128, lon: -74.0060),
      FeaturedCity(name: 'Rio de Janeiro', lat: -22.9068, lon: -43.1729),
    ],
  ),
  ContinentInfo(
    key: 'africa',
    displayNames: {'en': 'Africa', 'ar': 'أفريقيا'},
    restCountriesRegion: 'africa',
    featuredCities: [
      FeaturedCity(name: 'Cairo', lat: 30.0444, lon: 31.2357),
      FeaturedCity(name: 'Cape Town', lat: -33.9249, lon: 18.4241),
    ],
  ),
  ContinentInfo(
    key: 'oceania',
    displayNames: {'en': 'Oceania', 'ar': 'أوقيانوسيا'},
    restCountriesRegion: 'oceania',
    featuredCities: [
      FeaturedCity(name: 'Sydney', lat: -33.8688, lon: 151.2093),
      FeaturedCity(name: 'Auckland', lat: -36.8485, lon: 174.7633),
    ],
  ),
];

class CategoryDefinition {
  final Map<String, String> displayNames;
  final String openTripMapKinds;
  final String imageUrl;
  const CategoryDefinition({
    required this.displayNames,
    required this.openTripMapKinds,
    required this.imageUrl,
  });
  String displayName(String lang) =>
      displayNames[lang] ?? displayNames['en'] ?? '';
}

const List<CategoryDefinition> kCategories = [
  CategoryDefinition(
    displayNames: {'en': 'Cultural', 'ar': 'ثقافي'},
    openTripMapKinds: 'cultural',
    imageUrl: 'https://picsum.photos/seed/cultural/300/300',
  ),
  CategoryDefinition(
    displayNames: {'en': 'Historic', 'ar': 'تاريخي'},
    openTripMapKinds: 'historic',
    imageUrl: 'https://picsum.photos/seed/historic/300/300',
  ),
  CategoryDefinition(
    displayNames: {'en': 'Natural', 'ar': 'طبيعي'},
    openTripMapKinds: 'natural',
    imageUrl: 'https://picsum.photos/seed/natural/300/300',
  ),
  CategoryDefinition(
    displayNames: {'en': 'Architecture', 'ar': 'عمارة'},
    openTripMapKinds: 'architecture',
    imageUrl: 'https://picsum.photos/seed/architecture/300/300',
  ),
  CategoryDefinition(
    displayNames: {'en': 'Religious', 'ar': 'ديني'},
    openTripMapKinds: 'religion',
    imageUrl: 'https://picsum.photos/seed/religious/300/300',
  ),
];
