part of 'addresses_cubit.dart';

class AddressesState {
  const AddressesState({
    this.isLoading = false,
    this.isMutating = false,
    this.addresses = const [],
    this.loadError,
    this.actionError,
  });

  /// First load / retry (full-screen spinner).
  final bool isLoading;

  /// Delete / set-default in flight (overlay spinner, list stays visible).
  final bool isMutating;
  final List<AddressModel> addresses;

  /// Full-screen error when the list could not be loaded.
  final String? loadError;

  /// Transient error shown as a snackbar; the list stays visible.
  final String? actionError;

  AddressModel? get defaultAddress {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return null;
  }

  /// Errors reset when not passed (same convention as `HomeState`).
  AddressesState copyWith({
    bool? isLoading,
    bool? isMutating,
    List<AddressModel>? addresses,
    String? loadError,
    String? actionError,
  }) {
    return AddressesState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      addresses: addresses ?? this.addresses,
      loadError: loadError,
      actionError: actionError,
    );
  }
}
