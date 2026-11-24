import 'package:latlong2/latlong.dart';

/// Central place for every map / geocoding setting.
///
/// To move to another tile provider (MapTiler, Stadia, Google, ...) or a
/// different geocoder, change the values here (and the service
/// implementation) — nothing else in the app needs to know.
abstract final class MapConfig {
  /// Fallback center when the user's location is unavailable (Cairo).
  static const LatLng defaultCenter = LatLng(30.0444, 31.2357);

  static const double defaultZoom = 15;
  static const double locatedZoom = 17;
  static const double minZoom = 4;
  static const double maxZoom = 19;

  /// OSM public tiles are fine for development / low traffic only.
  /// Switch to a commercial provider before a large public release.
  static const String tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Must match the Android applicationId / iOS bundle id.
  static const String userAgentPackageName = 'com.abdallah.sooq';

  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Nominatim policy: identify the app and keep requests infrequent.
  static const String userAgent = 'Sooq/1.0 ($userAgentPackageName)';

  /// Wait for the map to settle before reverse-geocoding.
  static const Duration reverseGeocodeDebounce = Duration(milliseconds: 700);
}
