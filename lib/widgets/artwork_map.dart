import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/artwork.dart';
import '../models/user_position.dart';

class ArtworkMap extends StatelessWidget {
  static const LatLng _saoPaulo = LatLng(-23.5505, -46.6333);

  final List<Artwork> artworks;
  final UserPosition? position;
  final ValueChanged<Artwork> onMarkerTap;

  const ArtworkMap({
    super.key,
    required this.artworks,
    required this.position,
    required this.onMarkerTap,
  });

  LatLng get initialTarget {
    if (position != null) return LatLng(position!.latitude, position!.longitude);
    if (artworks.isNotEmpty) {
      return LatLng(artworks.first.latitude, artworks.first.longitude);
    }
    return _saoPaulo;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialTarget, zoom: 14),
      myLocationEnabled: position != null,
      myLocationButtonEnabled: position != null,
      markers: {
        for (final artwork in artworks)
          Marker(
            markerId: MarkerId(artwork.id),
            position: LatLng(artwork.latitude, artwork.longitude),
            infoWindow: InfoWindow(title: artwork.title),
            onTap: () => onMarkerTap(artwork),
          ),
      },
    );
  }
}
