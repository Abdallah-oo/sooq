import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sooq/core/config/map_config.dart';
import 'package:sooq/features/Address/data/services/map_failure.dart';

abstract interface class GeocodingService {
  /// Human readable address for a coordinate.
  Future<Either<MapFailure, String>> reverseGeocode(LatLng point);
}

/// OpenStreetMap Nominatim implementation.
///
/// Usage policy: max ~1 request/second and a valid User-Agent. The picker
/// debounces camera movement to stay within that. For production traffic use
/// a paid / self-hosted geocoder and swap this class only.
class NominatimGeocodingService implements GeocodingService {
  NominatimGeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<Either<MapFailure, String>> reverseGeocode(LatLng point) async {
    try {
      final uri = Uri.parse('${MapConfig.nominatimBaseUrl}/reverse').replace(
        queryParameters: {
          'format': 'jsonv2',
          'lat': '${point.latitude}',
          'lon': '${point.longitude}',
          'zoom': '18',
          'addressdetails': '1',
          'accept-language': 'en',
        },
      );

      final response = await _client
          .get(uri, headers: {'User-Agent': MapConfig.userAgent, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return const Left(MapFailure(MapFailureType.network, 'Address service is unavailable'));
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['error'] != null) {
        return const Left(MapFailure(MapFailureType.unknown, 'No address found for this location'));
      }

      final formatted = _format(json);
      if (formatted.isEmpty) {
        return const Left(MapFailure(MapFailureType.unknown, 'No address found for this location'));
      }
      return Right(formatted);
    } on TimeoutException {
      return const Left(MapFailure(MapFailureType.network, 'Request timeout, try again'));
    } on SocketException {
      return const Left(MapFailure(MapFailureType.network, 'No internet connection'));
    } catch (_) {
      return const Left(MapFailure(MapFailureType.unknown, 'Could not load the address'));
    }
  }

  /// "Street, Neighbourhood, City, Governorate" — falls back to display_name.
  String _format(Map<String, dynamic> json) {
    final address = (json['address'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};

    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = address[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return null;
    }

    final parts = <String?>[
      pick(['road', 'pedestrian', 'footway', 'residential']),
      pick(['neighbourhood', 'suburb', 'quarter', 'city_district']),
      pick(['city', 'town', 'village', 'municipality']),
      pick(['state']),
    ].whereType<String>().toSet().toList();

    if (parts.isNotEmpty) return parts.join(', ');
    return (json['display_name'] as String?)?.trim() ?? '';
  }
}
