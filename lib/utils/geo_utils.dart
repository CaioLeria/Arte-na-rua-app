import 'dart:math' as math;

const double _earthRadiusMeters = 6371000;

double distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadiusMeters * math.asin(math.min(1, math.sqrt(a)));
}

String formatDistance(double meters) {
  final rounded = meters.round();
  if (rounded < 1000) return '$rounded m';
  return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}
