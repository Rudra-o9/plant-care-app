class PlantIdentificationModel {
  final String inputImagePath;
  final PlantIdentificationResult? bestMatch;
  final List<PlantIdentificationResult> results;
  final List<String> predictedOrgans;
  final String? apiVersion;
  final int? quotaRemaining;
  /// True when the result came from the local AI fallback (PlantNet was unavailable).
  final bool isAiFallback;

  const PlantIdentificationModel({
    required this.inputImagePath,
    required this.bestMatch,
    required this.results,
    this.predictedOrgans = const [],
    this.apiVersion,
    this.quotaRemaining,
    this.isAiFallback = false,
  });

  bool get hasUsefulResult => bestMatch != null && results.isNotEmpty;

  List<PlantIdentificationResult> get topMatches => results.take(2).toList();
}

class PlantIdentificationResult {
  final double score;
  final String scientificName;
  final String scientificNameWithoutAuthor;
  final String genus;
  final String family;
  final List<String> commonNames;
  final String? imageUrl;

  const PlantIdentificationResult({
    required this.score,
    required this.scientificName,
    required this.scientificNameWithoutAuthor,
    required this.genus,
    required this.family,
    required this.commonNames,
    this.imageUrl,
  });

  String get displayName => scientificNameWithoutAuthor.isNotEmpty
      ? scientificNameWithoutAuthor
      : scientificName;

  String get commonName =>
      commonNames.isEmpty ? 'Unknown common name' : commonNames.first;

  bool get isLowConfidence => score < 0.5;

  factory PlantIdentificationResult.fromPlantNetJson(
    Map<String, dynamic> json,
  ) {
    final species = _map(json['species']);
    final genus = _map(species['genus']);
    final family = _map(species['family']);
    final scientificName = species['scientificName']?.toString() ?? '';
    final scientificNameWithoutAuthor =
        species['scientificNameWithoutAuthor']?.toString() ?? scientificName;
    final commonNames = _stringList(species['commonNames']);
    final images = json['images'];
    final firstImage = images is List && images.isNotEmpty
        ? _map(images.first)
        : const <String, dynamic>{};

    return PlantIdentificationResult(
      score: _double(json['score']),
      scientificName: scientificName,
      scientificNameWithoutAuthor: scientificNameWithoutAuthor,
      genus: genus['scientificNameWithoutAuthor']?.toString() ?? '',
      family: family['scientificNameWithoutAuthor']?.toString() ?? '',
      commonNames: commonNames,
      imageUrl: firstImage['url']?.toString(),
    );
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : <String, dynamic>{};

List<String> _stringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  // Plant.id returns this shape when multiple response languages are requested.
  if (value is Map) {
    return value.values
        .whereType<List>()
        .expand((names) => names)
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return <String>[];
}

double _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
