import 'dart:math';

class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  double distanceTo(GeoPoint other) {
    const earthRadius = 6371000.0;
    final dLat = _rad(other.lat - lat);
    final dLng = _rad(other.lng - lng);
    final a = pow(sin(dLat / 2), 2) +
        cos(_rad(lat)) * cos(_rad(other.lat)) * pow(sin(dLng / 2), 2);
    return 2 * earthRadius * asin(sqrt(a));
  }

  static double _rad(double deg) => deg * pi / 180;
}
