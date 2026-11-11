import 'curation.dart';

class Artwork {
  final String id;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String? photoName;
  final String? photoAuthor;
  final List<String> types;
  final Curation? curation;

  Artwork({
    required this.id,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoName,
    this.photoAuthor,
    this.types = const [],
    this.curation,
  });

  factory Artwork.fromPlaceJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List?;
    final firstPhoto =
        (photos != null && photos.isNotEmpty) ? photos[0] as Map : null;
    final authors = firstPhoto?['authorAttributions'] as List?;
    final location = json['location'] as Map?;

    return Artwork(
      id: json['id'] ?? '',
      title: (json['displayName'] as Map?)?['text'] ?? '',
      address: json['formattedAddress'] ?? '',
      latitude: (location?['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (location?['longitude'] as num?)?.toDouble() ?? 0.0,
      photoName: firstPhoto?['name'],
      photoAuthor: (authors != null && authors.isNotEmpty)
          ? (authors[0] as Map)['displayName']
          : null,
      types: List<String>.from(json['types'] ?? const []),
    );
  }

  Artwork withCuration(Curation? curation) {
    return Artwork(
      id: id,
      title: title,
      address: address,
      latitude: latitude,
      longitude: longitude,
      photoName: photoName,
      photoAuthor: photoAuthor,
      types: types,
      curation: curation,
    );
  }

  bool get isCurated => curation != null;

  String get audioText {
    final description = curation?.audioDescription;
    if (description != null && description.isNotEmpty) return description;
    return '$title. Endereço: $address. Esta obra ainda não tem audiodescrição.';
  }
}
