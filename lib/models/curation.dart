class Curation {
  final String placeId;
  final String title;
  final String? artistName;
  final int? year;
  final String? history;
  final String? audioDescription;
  final List<String> referencePhotos;

  Curation({
    required this.placeId,
    required this.title,
    this.artistName,
    this.year,
    this.history,
    this.audioDescription,
    this.referencePhotos = const [],
  });

  factory Curation.fromJson(Map<String, dynamic> json) {
    return Curation(
      placeId: json['placeId'] ?? '',
      title: json['title'] ?? '',
      artistName: json['artistName'],
      year: json['year'],
      history: json['history'],
      audioDescription: json['audioDescription'],
      referencePhotos: List<String>.from(json['referencePhotos'] ?? const []),
    );
  }
}
