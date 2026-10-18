class PlantJournalEntry {
  final String id;
  final String note;
  final DateTime createdAt;
  final String imageData;

  const PlantJournalEntry({
    required this.id,
    required this.note,
    required this.createdAt,
    this.imageData = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'imageData': imageData,
  };

  factory PlantJournalEntry.fromMap(Map<String, dynamic> map) =>
      PlantJournalEntry(
        id: map['id']?.toString() ?? '',
        note: map['note']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        imageData: map['imageData']?.toString() ?? '',
      );
}
