class RecognitionResult {
  final String? placeId;
  final String? aiDescription;

  RecognitionResult({
    this.placeId,
    this.aiDescription,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      placeId: json['placeId'],
      aiDescription: json['aiDescription'] ?? json['description'],
    );
  }

  bool get isFound => placeId != null && placeId!.isNotEmpty;
}
