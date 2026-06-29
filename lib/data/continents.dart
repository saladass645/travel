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

// Featured global destinations. We fetch OpenTripMap POIs around each city's
// lat/lon. Keep this list focused on iconic destinations to balance variety
// against API call volume (each city = 1 radius call + N detail calls).
const List<ContinentInfo> kContinents = [
  ContinentInfo(
    key: 'asia',
    displayNames: {'en': 'Asia', 'ar': 'آسيا'},
    restCountriesRegion: 'asia',
    featuredCities: [
      FeaturedCity(name: 'Tokyo', lat: 35.6895, lon: 139.6917),
      FeaturedCity(name: 'Kyoto', lat: 35.0116, lon: 135.7681),
      FeaturedCity(name: 'Bangkok', lat: 13.7563, lon: 100.5018),
      FeaturedCity(name: 'Bali', lat: -8.3405, lon: 115.0920),
      FeaturedCity(name: 'Singapore', lat: 1.3521, lon: 103.8198),
      FeaturedCity(name: 'Seoul', lat: 37.5665, lon: 126.9780),
      FeaturedCity(name: 'Hong Kong', lat: 22.3193, lon: 114.1694),
      FeaturedCity(name: 'Dubai', lat: 25.2048, lon: 55.2708),
      FeaturedCity(name: 'Istanbul', lat: 41.0082, lon: 28.9784),
    ],
  ),
  ContinentInfo(
    key: 'europe',
    displayNames: {'en': 'Europe', 'ar': 'أوروبا'},
    restCountriesRegion: 'europe',
    featuredCities: [
      FeaturedCity(name: 'Paris', lat: 48.8566, lon: 2.3522),
      FeaturedCity(name: 'Rome', lat: 41.9028, lon: 12.4964),
      FeaturedCity(name: 'London', lat: 51.5074, lon: -0.1278),
      FeaturedCity(name: 'Barcelona', lat: 41.3851, lon: 2.1734),
      FeaturedCity(name: 'Amsterdam', lat: 52.3676, lon: 4.9041),
      FeaturedCity(name: 'Prague', lat: 50.0755, lon: 14.4378),
      FeaturedCity(name: 'Vienna', lat: 48.2082, lon: 16.3738),
      FeaturedCity(name: 'Lisbon', lat: 38.7223, lon: -9.1393),
      FeaturedCity(name: 'Santorini', lat: 36.3932, lon: 25.4615),
    ],
  ),
  ContinentInfo(
    key: 'americas',
    displayNames: {'en': 'Americas', 'ar': 'الأمريكتان'},
    restCountriesRegion: 'americas',
    featuredCities: [
      FeaturedCity(name: 'New York', lat: 40.7128, lon: -74.0060),
      FeaturedCity(name: 'San Francisco', lat: 37.7749, lon: -122.4194),
      FeaturedCity(name: 'Vancouver', lat: 49.2827, lon: -123.1207),
      FeaturedCity(name: 'Mexico City', lat: 19.4326, lon: -99.1332),
      FeaturedCity(name: 'Cusco', lat: -13.5320, lon: -71.9675),
      FeaturedCity(name: 'Rio de Janeiro', lat: -22.9068, lon: -43.1729),
      FeaturedCity(name: 'Buenos Aires', lat: -34.6037, lon: -58.3816),
      FeaturedCity(name: 'Havana', lat: 23.1136, lon: -82.3666),
    ],
  ),
  ContinentInfo(
    key: 'africa',
    displayNames: {'en': 'Africa', 'ar': 'أفريقيا'},
    restCountriesRegion: 'africa',
    featuredCities: [
      FeaturedCity(name: 'Cairo', lat: 30.0444, lon: 31.2357),
      FeaturedCity(name: 'Marrakech', lat: 31.6295, lon: -7.9811),
      FeaturedCity(name: 'Cape Town', lat: -33.9249, lon: 18.4241),
      FeaturedCity(name: 'Nairobi', lat: -1.2921, lon: 36.8219),
      FeaturedCity(name: 'Zanzibar', lat: -6.1659, lon: 39.2026),
      FeaturedCity(name: 'Lagos', lat: 6.5244, lon: 3.3792),
    ],
  ),
  ContinentInfo(
    key: 'oceania',
    displayNames: {'en': 'Oceania', 'ar': 'أوقيانوسيا'},
    restCountriesRegion: 'oceania',
    featuredCities: [
      FeaturedCity(name: 'Sydney', lat: -33.8688, lon: 151.2093),
      FeaturedCity(name: 'Melbourne', lat: -37.8136, lon: 144.9631),
      FeaturedCity(name: 'Auckland', lat: -36.8485, lon: 174.7633),
      FeaturedCity(name: 'Queenstown', lat: -45.0312, lon: 168.6626),
      FeaturedCity(name: 'Fiji', lat: -17.7134, lon: 178.0650),
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
