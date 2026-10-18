import 'plant_journal_entry.dart';

/// Model for a plant saved in the user's collection or returned from identification.
class PlantModel {
  final String id;
  final String name;
  final String scientificName;
  final String description;
  final String imageUrl;
  final String careLevel; // Low, Medium, High
  final int wateringFrequencyDays;
  final String sunlight; // Direct, Bright Indirect, Low Light
  final String temperature; // e.g. "18°C - 27°C"
  final String soilType; // Well-draining peat mix, etc.
  final DateTime lastWatered;

  /// Calendar days on which care was explicitly completed for this plant.
  final List<String> careActivityDates;
  final List<PlantJournalEntry> journalEntries;
  final bool isFavorite;
  final String customNotes;
  final double matchConfidence; // Optional for identification result

  const PlantModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrl,
    required this.careLevel,
    required this.wateringFrequencyDays,
    required this.sunlight,
    required this.temperature,
    required this.soilType,
    required this.lastWatered,
    this.careActivityDates = const [],
    this.journalEntries = const [],
    this.isFavorite = false,
    this.customNotes = '',
    this.matchConfidence = 0.0,
  });

  DateTime get nextWateringDate =>
      lastWatered.add(Duration(days: wateringFrequencyDays));

  bool get needsWateringToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = DateTime(
      nextWateringDate.year,
      nextWateringDate.month,
      nextWateringDate.day,
    );
    return next.isBefore(today) || next.isAtSameMomentAs(today);
  }

  PlantModel copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? description,
    String? imageUrl,
    String? careLevel,
    int? wateringFrequencyDays,
    String? sunlight,
    String? temperature,
    String? soilType,
    DateTime? lastWatered,
    List<String>? careActivityDates,
    List<PlantJournalEntry>? journalEntries,
    bool? isFavorite,
    String? customNotes,
    double? matchConfidence,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      careLevel: careLevel ?? this.careLevel,
      wateringFrequencyDays:
          wateringFrequencyDays ?? this.wateringFrequencyDays,
      sunlight: sunlight ?? this.sunlight,
      temperature: temperature ?? this.temperature,
      soilType: soilType ?? this.soilType,
      lastWatered: lastWatered ?? this.lastWatered,
      careActivityDates: careActivityDates ?? this.careActivityDates,
      journalEntries: journalEntries ?? this.journalEntries,
      isFavorite: isFavorite ?? this.isFavorite,
      customNotes: customNotes ?? this.customNotes,
      matchConfidence: matchConfidence ?? this.matchConfidence,
    );
  }
}
