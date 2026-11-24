part of 'address_picker_cubit.dart';

class AddressPickerState {
  const AddressPickerState({
    required this.center,
    this.address,
    this.isResolving = false,
    this.isLocating = false,
    this.resolveFailed = false,
  });

  /// Center of the map = the delivery point.
  final LatLng center;

  /// Reverse-geocoded address of [center] (null while loading or on failure).
  final String? address;
  final bool isResolving;
  final bool isLocating;
  final bool resolveFailed;

  AddressPickerState copyWith({
    LatLng? center,
    String? address,
    bool clearAddress = false,
    bool? isResolving,
    bool? isLocating,
    bool? resolveFailed,
  }) {
    return AddressPickerState(
      center: center ?? this.center,
      address: clearAddress ? null : (address ?? this.address),
      isResolving: isResolving ?? this.isResolving,
      isLocating: isLocating ?? this.isLocating,
      resolveFailed: resolveFailed ?? this.resolveFailed,
    );
  }
}
