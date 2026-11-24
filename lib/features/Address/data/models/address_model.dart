import 'package:latlong2/latlong.dart';

class AddressModel {
  /// Empty for a draft that has not been saved yet.
  final String id;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? phone;
  final String? notes;
  final bool isDefault;

  const AddressModel({
    this.id = '',
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.building,
    this.floor,
    this.apartment,
    this.phone,
    this.notes,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['full_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      apartment: json['apartment'] as String?,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  /// Payload for insert / update. `user_id` is filled by the DB (auth.uid()).
  Map<String, dynamic> toJson() => {
    'label': label,
    'full_address': fullAddress.trim(),
    'latitude': latitude,
    'longitude': longitude,
    'building': _nullIfBlank(building),
    'floor': _nullIfBlank(floor),
    'apartment': _nullIfBlank(apartment),
    'phone': _nullIfBlank(phone),
    'notes': _nullIfBlank(notes),
    'is_default': isDefault,
  };

  LatLng get location => LatLng(latitude, longitude);

  /// "Building 12 · Floor 3 · Apt 5" (only the parts that exist).
  String get details {
    final parts = <String>[
      if (_hasText(building)) 'Building ${building!.trim()}',
      if (_hasText(floor)) 'Floor ${floor!.trim()}',
      if (_hasText(apartment)) 'Apt ${apartment!.trim()}',
    ];
    return parts.join(' · ');
  }

  static bool _hasText(String? v) => v != null && v.trim().isNotEmpty;
  static String? _nullIfBlank(String? v) => _hasText(v) ? v!.trim() : null;
}
