import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/user_position.dart';

enum LocationStatus {
  initial,
  searching,
  available,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class LocationException implements Exception {
  final LocationStatus status;
  final String message;

  LocationException(this.status, this.message);

  factory LocationException.forStatus(LocationStatus status) {
    switch (status) {
      case LocationStatus.denied:
        return LocationException(status,
            'Sem a sua localização, mostramos as obras por região.');
      case LocationStatus.deniedForever:
        return LocationException(status,
            'Sem a sua localização, mostramos as obras por região.');
      case LocationStatus.serviceDisabled:
        return LocationException(status, 'Ative a localização do aparelho.');
      default:
        return LocationException(
            LocationStatus.error, 'Não conseguimos achar sua posição.');
    }
  }

  @override
  String toString() => message;
}

class LocationService {
  Future<UserPosition> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw LocationException.forStatus(LocationStatus.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw LocationException.forStatus(LocationStatus.deniedForever);
      }
      if (permission == LocationPermission.denied) {
        throw LocationException.forStatus(LocationStatus.denied);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return UserPosition(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationException {
      rethrow;
    } on TimeoutException {
      throw LocationException.forStatus(LocationStatus.error);
    } catch (_) {
      throw LocationException.forStatus(LocationStatus.error);
    }
  }

  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }
}
