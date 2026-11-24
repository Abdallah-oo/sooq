enum MapFailureType {
  locationServiceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  network,
  unknown,
}

class MapFailure {
  const MapFailure(this.type, this.message);

  final MapFailureType type;
  final String message;
}
