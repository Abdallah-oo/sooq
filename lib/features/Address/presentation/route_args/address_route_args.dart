import 'package:latlong2/latlong.dart';
import 'package:sooq/features/Address/data/models/address_model.dart';

/// Passed to the map picker. `editing == null` means "add a new address".
class AddressPickerArgs {
  const AddressPickerArgs({this.editing});

  final AddressModel? editing;
}

/// Passed from the map picker to the details form.
class AddressFormArgs {
  const AddressFormArgs({
    required this.location,
    required this.resolvedAddress,
    this.editing,
  });

  final LatLng location;

  /// Reverse-geocoded text (may be empty if geocoding failed) — editable in the form.
  final String resolvedAddress;
  final AddressModel? editing;
}
