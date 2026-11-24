import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:sooq/core/config/map_config.dart';
import 'package:sooq/features/Address/data/services/geocoding_service.dart';
import 'package:sooq/features/Address/data/services/location_service.dart';
import 'package:sooq/features/Address/data/services/map_failure.dart';

part 'address_picker_state.dart';

class AddressPickerCubit extends Cubit<AddressPickerState> {
  AddressPickerCubit({
    required LocationService location,
    required GeocodingService geocoding,
    required LatLng initialCenter,
  })  : _location = location,
        _geocoding = geocoding,
        super(AddressPickerState(center: initialCenter));

  final LocationService _location;
  final GeocodingService _geocoding;

  Timer? _debounce;

  /// Point whose request is currently running (null when idle).
  LatLng? _inFlight;

  /// Increments on every request so a slow, outdated response can never
  /// overwrite the address of the point the user is looking at now.
  int _requestId = 0;

  /// Called on every camera change. Reverse-geocodes once the map settles.
  void onCameraMoved(LatLng center) {
    final isSettled = !state.isResolving && state.address != null && _isSame(center, state.center);
    if (isSettled) return; // duplicate event from a programmatic move

    if (!state.isResolving) emit(state.copyWith(isResolving: true));

    _debounce?.cancel();
    _debounce = Timer(MapConfig.reverseGeocodeDebounce, () => _resolve(center));
  }

  Future<void> retry() => _resolve(state.center);

  Future<void> _resolve(LatLng center) async {
    // Same point already being requested: its response will finish the job.
    if (_isSame(center, _inFlight)) return;

    // Moved away and came back to an already resolved point: no request needed.
    if (state.address != null && _isSame(center, state.center)) {
      emit(state.copyWith(isResolving: false));
      return;
    }

    _inFlight = center;
    final requestId = ++_requestId;
    emit(
      state.copyWith(center: center, isResolving: true, clearAddress: true, resolveFailed: false),
    );

    final result = await _geocoding.reverseGeocode(center);
    if (isClosed || requestId != _requestId) return;

    _inFlight = null;
    result.fold(
      (_) => emit(state.copyWith(isResolving: false, resolveFailed: true)),
      (address) => emit(state.copyWith(isResolving: false, address: address)),
    );
  }

  /// Returns the GPS position (or why it failed) so the view can move the map.
  Future<Either<MapFailure, LatLng>> locateMe() async {
    if (state.isLocating) {
      return const Left(MapFailure(MapFailureType.unknown, 'Already locating'));
    }
    emit(state.copyWith(isLocating: true));
    final result = await _location.getCurrentLocation();
    if (!isClosed) emit(state.copyWith(isLocating: false));
    return result;
  }

  Future<void> openLocationSettings() => _location.openLocationSettings();

  Future<void> openAppSettings() => _location.openAppSettings();

  /// ~1 m tolerance.
  bool _isSame(LatLng a, LatLng? b) {
    if (b == null) return false;
    return (a.latitude - b.latitude).abs() < 1e-5 && (a.longitude - b.longitude).abs() < 1e-5;
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
