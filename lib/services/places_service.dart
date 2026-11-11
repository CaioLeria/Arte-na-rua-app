import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/artwork.dart';
import '../models/artwork_distance.dart';
import '../models/user_position.dart';
import '../utils/geo_utils.dart';

class PlacesService {
  static const String baseUrl = 'https://places.googleapis.com/v1';
  static const String apiKey = String.fromEnvironment('PLACES_API_KEY');

  static const String _searchFields =
      'places.id,places.displayName,places.formattedAddress,places.location,places.photos,places.types';
  static const String _detailFields =
      'id,displayName,formattedAddress,location,photos,types';

  static const List<String> _noiseTypes = [
    'restaurant',
    'bar',
    'cafe',
    'store',
    'lodging',
  ];
  static const List<String> _artKeywords = [
    'grafite',
    'graffiti',
    'mural',
    'street art',
    'arte urbana',
    'beco',
  ];

  final http.Client client;
  final Duration timeout;

  PlacesService({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : client = client ?? http.Client();

  Future<List<Artwork>> searchArtworks(
    String region, {
    Set<String> curatedIds = const {},
  }) async {
    final queries = [
      'street art em $region, São Paulo',
      'grafite mural em $region, São Paulo',
    ];
    final byId = <String, Artwork>{};
    for (final query in queries) {
      final found = await searchText(query);
      for (final artwork in found) {
        byId.putIfAbsent(artwork.id, () => artwork);
      }
    }
    return filterStreetArt(byId.values.toList(), curatedIds: curatedIds);
  }

  Future<List<Artwork>> searchText(
    String textQuery, {
    Map<String, dynamic> extraBody = const {},
  }) async {
    final body = {
      'textQuery': textQuery,
      'languageCode': 'pt-BR',
      'regionCode': 'BR',
      'pageSize': 20,
      ...extraBody,
    };
    final json = await _send(() => client.post(
          Uri.parse('$baseUrl/places:searchText'),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': _searchFields,
          },
          body: jsonEncode(body),
        ));
    final places = (json['places'] as List?) ?? const [];
    return places
        .map((p) => Artwork.fromPlaceJson(p as Map<String, dynamic>))
        .toList();
  }

  Future<List<ArtworkDistance>> searchNearby(
    UserPosition position, {
    double radiusMeters = 2000,
    Set<String> curatedIds = const {},
  }) async {
    final bias = {
      'locationBias': {
        'circle': {
          'center': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'radius': radiusMeters,
        },
      },
    };
    final byId = <String, Artwork>{};
    for (final query in ['street art', 'grafite mural']) {
      for (final artwork in await searchText(query, extraBody: bias)) {
        byId.putIfAbsent(artwork.id, () => artwork);
      }
    }

    final filtered =
        filterStreetArt(byId.values.toList(), curatedIds: curatedIds);
    final result = filtered
        .map((a) => ArtworkDistance(
              artwork: a,
              distanceMeters: distanceInMeters(
                position.latitude,
                position.longitude,
                a.latitude,
                a.longitude,
              ),
            ))
        .where((d) => d.distanceMeters <= radiusMeters)
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return result;
  }

  Future<Artwork> getArtworkById(String id) async {
    final json = await _send(() => client.get(
          Uri.parse('$baseUrl/places/$id'),
          headers: {
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask': _detailFields,
          },
        ));
    return Artwork.fromPlaceJson(json);
  }

  List<Artwork> filterStreetArt(
    List<Artwork> places, {
    Set<String> curatedIds = const {},
  }) {
    return places.where((place) {
      if (place.isCurated || curatedIds.contains(place.id)) return true;
      final isNoise = place.types.any(_noiseTypes.contains);
      if (!isNoise) return true;
      final name = place.title.toLowerCase();
      return _artKeywords.any(name.contains);
    }).toList();
  }

  String photoUrl(String photoName, {int maxWidthPx = 600}) {
    return '$baseUrl/$photoName/media?maxWidthPx=$maxWidthPx&key=$apiKey';
  }

  List<Artwork> search(List<Artwork> artworks, String term) {
    final query = term.trim().toLowerCase();
    if (query.isEmpty) return artworks;
    return artworks
        .where((a) => a.title.toLowerCase().contains(query))
        .toList();
  }

  Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() call) async {
    final response = await call().timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro na API Places (${response.statusCode}): ${response.body}');
    }

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}
